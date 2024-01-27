#!/bin/bash

set -euo pipefail # Enable strict error handling

# GitHub credentials (replace with your actual values)
export GITHUB_USERNAME="your_username"
export GITHUB_TOKEN="your_personal_access_token"

# Get repository name from user
read -p "Enter the desired repository name: " REPO_NAME

# Create and navigate to repository directory
mkdir -p "$REPO_NAME" && cd "$REPO_NAME"

# Initialize Git repository with main branch
git init -b main

# Create README.md with repository name
echo "# $REPO_NAME" > README.md

# Add and commit README.md
git add README.md
git commit -m "Initial commit"
# Create remote repository on GitHub
curl -u "$GITHUB_USERNAME:$GITHUB_TOKEN" -X POST https://api.github.com/user/repos -d '{"name":"'"$REPO_NAME"'", "private": false}'

# Add remote and push initial commit
git remote add origin "git@github.com:$GITHUB_USERNAME/$REPO_NAME.git"
git push -u origin main

# Open the repository in a code editor (if available)
if command -v code &>/dev/null; then
  code .
elif command -v nvim &>/dev/null; then
  nvim .
else
  echo "Neither 'vs code' nor 'nvim' is available. Please open the repository manually."
fi 