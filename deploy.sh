#!/usr/bin/env bash
#
# Deploy the built site to the CSAIL web directory.
#
#   ./deploy.sh           # dry run  — shows what would change, touches nothing
#   ./deploy.sh --apply   # real run
#
# IMPORTANT: /afs/csail/group/ei/www/ is the SHARED web root for the `ei` group.
# It holds other sites (e.g. the ./ei/ subtree) that this repo does not produce.
# Never use `rsync --delete` here: it would delete them. This script is additive,
# and removes only the specific stale files listed in STALE below.

set -euo pipefail

REMOTE_USER="${CSAIL_USER:-dhm}"
REMOTE_HOST="${CSAIL_HOST:-align-3.csail.mit.edu}"
# Override with: CSAIL_WWW=/some/other/path ./deploy.sh
# NOTE the historical deploy was `scp -r ./_site <host>:/afs/csail/group/ei/www/`,
# which (no trailing slash) creates a `_site` SUBDIRECTORY. Confirm where the live
# site is actually served from before changing this.
REMOTE_DIR="${CSAIL_WWW:-/afs/csail/group/ei/www/_site}"
SITE_URL="https://algorithmicalignment.csail.mit.edu/"

cd "$(dirname "$0")"

APPLY=0
case "${1:-}" in
  --apply) APPLY=1 ;;
  ""|--dry-run) APPLY=0 ;;
  *) echo "usage: $0 [--apply]" >&2; exit 2 ;;
esac

# Files this repo used to publish and no longer should. Removed explicitly,
# because without --delete rsync leaves them on the server forever.
STALE=(
  "notes.txt"
  "docs/assets/jessica.jpg"
  "docs/assets/Lennart.JPG"
  "docs/assets/andreas.png"
  "docs/assets/dylan.png"
  "docs/assets/phillip.jpeg"
  "docs/assets/rjy.png"
)

say() { printf '\n\033[1m== %s\033[0m\n' "$*"; }

# --- 1. Kerberos ------------------------------------------------------------
say "Kerberos ticket"
if klist -s 2>/dev/null; then
  klist 2>/dev/null | sed -n '2p;5p'
else
  echo "No valid ticket; running kinit..."
  kinit "${REMOTE_USER}@CSAIL.MIT.EDU"
fi

# --- 2. Build ---------------------------------------------------------------
say "Building site"
bundle exec jekyll build

# Sanity: refuse to push an empty or broken build.
[[ -f _site/index.html && -f _site/team/index.html ]] \
  || { echo "ERROR: _site looks incomplete; aborting." >&2; exit 1; }
if grep -rq 'BIO_PLACEHOLDER' _site/ 2>/dev/null; then
  echo "ERROR: _site still contains BIO_PLACEHOLDER; aborting." >&2; exit 1
fi
echo "OK: $(find _site -type f | wc -l | tr -d ' ') files"

# --- 3. Connection (multiplexed so Duo prompts only once) -------------------
# Keep this path SHORT: Unix domain sockets are capped at ~104 chars, and macOS
# $TMPDIR is a long /var/folders/... path that blows the limit. %C is a hash of
# the connection parameters.
SOCK="/tmp/aag-%C"
SSH_OPTS=(-o ControlMaster=auto -o ControlPath="$SOCK" -o ControlPersist=5m)

say "Connecting to $REMOTE_HOST (approve the Duo prompt if asked)"
ssh "${SSH_OPTS[@]}" "${REMOTE_USER}@${REMOTE_HOST}" \
    "test -d '$REMOTE_DIR' && echo 'connected; remote dir OK'"

cleanup() { ssh "${SSH_OPTS[@]}" -O exit "${REMOTE_USER}@${REMOTE_HOST}" 2>/dev/null || true; }
trap cleanup EXIT

# --- 3b. Confirm we are updating THIS site, not some other one --------------
# The target must already look like a previous deploy of this site. Without this
# check a wrong REMOTE_DIR silently dumps 63 files into someone else's web root.
say "Verifying target is this site"
if ssh "${SSH_OPTS[@]}" "${REMOTE_USER}@${REMOTE_HOST}" \
     "test -f '$REMOTE_DIR/team/index.html' && grep -q 'Algorithmic Alignment' '$REMOTE_DIR/index.html'" 2>/dev/null; then
  echo "OK: $REMOTE_DIR holds an existing deploy of this site"
else
  cat >&2 <<ERR

ERROR: $REMOTE_DIR does not look like this site.
Expected team/index.html and an index.html mentioning "Algorithmic Alignment".

Deploying anyway could overwrite an unrelated site. Find the real docroot first:

  ssh ${REMOTE_USER}@${REMOTE_HOST} 'ls /afs/csail/group/ei/www/ /afs/csail/group/ei/www/_site/ 2>&1 | head -40'

then re-run with:  CSAIL_WWW=<correct/path> $0 ${1:-}
ERR
  exit 1
fi

# --- 4. Sync (additive — NO --delete) ---------------------------------------
if [[ $APPLY -eq 1 ]]; then
  say "Syncing (real)"
  RSYNC_FLAGS=(-av)
else
  say "Syncing (DRY RUN — nothing will change)"
  RSYNC_FLAGS=(-avn)
fi
rsync "${RSYNC_FLAGS[@]}" -e "ssh ${SSH_OPTS[*]}" \
      ./_site/ "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"

# --- 5. Remove stale files ---------------------------------------------------
say "Stale files"
for f in "${STALE[@]}"; do
  if ssh "${SSH_OPTS[@]}" "${REMOTE_USER}@${REMOTE_HOST}" "test -e '$REMOTE_DIR/$f'"; then
    if [[ $APPLY -eq 1 ]]; then
      ssh "${SSH_OPTS[@]}" "${REMOTE_USER}@${REMOTE_HOST}" "rm -f '$REMOTE_DIR/$f'"
      echo "  removed  $f"
    else
      echo "  WOULD REMOVE  $f"
    fi
  else
    echo "  absent   $f"
  fi
done

# --- 6. Verify ---------------------------------------------------------------
if [[ $APPLY -eq 1 ]]; then
  say "Verifying live site"
  for path in "" "team/" "research/" "blog/" "contact/"; do
    printf '  %-12s %s\n' "/$path" "$(curl -s -o /dev/null -w '%{http_code}' "${SITE_URL}${path}")"
  done
  printf '  %-12s %s (404 expected)\n' "/notes.txt" \
    "$(curl -s -o /dev/null -w '%{http_code}' "${SITE_URL}notes.txt")"
  echo
  echo "Done. Open ${SITE_URL} and check it looks right."
  echo "Remember to commit and push to GitHub as well."
else
  echo
  echo "Dry run complete. Re-run with --apply to deploy for real."
fi
