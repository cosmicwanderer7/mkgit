#!/bin/bash

git_init() {
  # Create and navigate to repository directory
  mkdir -p "$REPO_NAME" && cd "$REPO_NAME"

  # Initialize Git repository with main branch
  git init -b main

  # Create README.md with repository name
  echo "# $REPO_NAME" > README.md

  # Add initial commit
  git add README.md
  git commit -m "Initial commit: $REPO_NAME"

  # Create remote repository on GitHub
  create_remote_repo "$REPO_NAME" "$visibility" "$REPO_DESCRIPTION" "$LICENSE"

  # Add remote and push initial commit
  git remote add origin "git@github.com:$GITHUB_USERNAME/$REPO_NAME.git"

  if [ -n "$LICENSE" ]; then
    # Pull changes from remote and rebase local changes on top
    git pull --rebase origin main
    
    # Push the rebased changes to remote
    git push origin main
  else
    # Push local changes to remote
    git push origin main
  fi
}
