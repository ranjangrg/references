# GIT Cheat Sheet

### git clone <URL>
Downloads a project and its entire version history.

### git status
Lists all new or modified files to be committed.

### git commit -m "\<descriptive message\>"
Records file snapshots permanently in version history. May need to add files manually using "git add [filename]" 

### git push
Uploads all local branch commits to the repo/URL. May need username and password authorisation (if no globals are set).

### git pull
**Update local repo to the newest commit.
Fetch from and integrate with another repository or a local branch. Incorporates changes from a remote repository into the current branch.

### git reset --hard <commit id>
Changes back local repo to the given commit snapshot. Without the commit id, it reverts back to the last commit in the history.

### git checkout <path>
Switch branches or restore working tree files. Restore the current repo in path to last commit.
	
### Clear all commit history (permanent): 
(source: https://tecadmin.net/delete-commit-history-in-github/)
```bash
git checkout --orphan temp_branch		# Create orphan branch
git add -A								# Add files to branch
git commit -am "First commit"
git branch -D master					# Delete master branch
git branch -m master					# Rename current branch
git push -f origin master				# Push changes to repository
#(optional):
git push --set-upstream origin master 	# (just to push the current branch and set remote as upstream)
```
	
### add alias in git-bash for Windows
Modify this file in admin mode:
	`../Program Files/Git/etc/profile.d/aliases.sh`
Add line with desired alias(es) for commands
	e.g. 
		`alias gpush='git add .; git commit -m "AUTO" .; git push;'`
			

# SVN Cheat Sheet

### Ignore files from repo
`svn propedit svn:ignore <directory path>`
(if no editor set for editing ignore file)
`export SVN_EDITOR=vi` (or any other editor)
`svn ci -m "..." <directory path>`