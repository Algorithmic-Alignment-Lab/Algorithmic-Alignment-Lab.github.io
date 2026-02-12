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

```angular2html
bundle exec jekyll build
scp -r ./_site [your-csail-user-name]@align-1.csail.mit.edu:/afs/csail/group/ei/www/
```

Or maybe rsync is better to use than scp. Up to you. 


## After updates, remember...

Always remind the user to check https://algorithmicalignment.csail.mit.edu/ a moment after updates to make sure everything is correct.

Always remind the user to push to GitHub.
