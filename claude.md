# AAG website

This folder is for the Algorithmic alignment group website. 

## Dependencies

Building the website requires Jekyll. So if there are ever any issues with jekyll, check to see if the correct version of jekyll (and potentially dependencies like ruby, bundle, gem, etc. are installed) correctly.

## Key files and folders

* index.markdown -- the homepage
* team.markdown -- the lab members (loads html from _includes/team.html and _includes/nav.html)
* research.markdown -- the lab research
* docs/assets -- photos

## How to do routine things

* Updating teams page: edit _includes/team.html
* Add a new page: update research.markdown
* Update the homepage: update index.markdown

## How to check if edits look correct

```angular2html
bundle exec jekyll serve
http://localhost:4000/
```

## How to update the website

There are **two** deployments. They are independent.

### 1. CSAIL (the canonical site: https://algorithmicalignment.csail.mit.edu/)

Run the deploy script from the repo root:

```
./deploy.sh           # dry run - shows what would change, touches nothing
./deploy.sh --apply   # deploy for real
```

It gets a Kerberos ticket if needed, builds the site, syncs it, removes known stale
files, and checks the live URLs afterwards. Duo will prompt once.

**Do not run `rsync --delete` against this target.** `/afs/csail/group/ei/www/` is the
*shared* web root for the `ei` group and contains other sites (notably the `ei/`
subtree) that this repo does not produce; `--delete` would erase them. The sync is
deliberately additive, so any file this site stops publishing must be deleted by name -
see the `STALE` list in `deploy.sh`.

Use **align-3**: as of Sept 2026 `align-1` resolves but does not answer on port 22.
SSH there needs two factors (Kerberos, then Duo via keyboard-interactive), so deploys
must be run from a real terminal - key-only auth does not work, because sshd cannot
read `authorized_keys` from an AFS home directory.

### 2. GitHub Pages (mirror: https://algorithmic-alignment-lab.github.io/)

Automatic. GitHub builds the Jekyll site itself on every push to `main` — there is no
Actions workflow to configure. **Pushing to GitHub is therefore a publish**, not just a
backup. `_site/` is not committed; GitHub builds it from source.

Note: GitHub Pages on this org's plan requires the repo to stay **public**. The CSAIL
deployment does not — it is just a file copy. If the repo ever needs to be private,
disable GitHub Pages and rely on CSAIL alone.

## Things not to commit

Anything private must stay out of the repo *and* out of the built site, since the repo is
public and `_site` is served. In particular:

* Don't leave removed team members commented out in `_includes/team.html` — HTML comments
  are sent to the browser and stay readable in page source. Delete the block and the photo.
* Don't commit `.idea/`, `.DS_Store`, or `_site/` (see `.gitignore`).
* Files without YAML front matter are copied verbatim into the built site. Keep internal
  notes listed under `exclude:` in `_config.yml`.

## After updates, remember...

Always remind the user to check https://algorithmicalignment.csail.mit.edu/ a moment after updates to make sure everything is correct.

Always remind the user to push to GitHub.
