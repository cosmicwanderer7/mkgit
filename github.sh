#!/bin/bash

# Enable strict error handling
set -euo pipefail

# GitHub credentials (replace with your actual values)
export GITHUB_USERNAME="your_username"
export GITHUB_TOKEN="your_personal_access_token"

# Function to create initial commit
create_initial_commit() {
    git add README.md
    git commit -m "Initial commit"
}

# Function to create remote repository on GitHub
create_remote_repo() {
    local repo_name="$1"
    local visibility="$2" # 'public' or 'private'
    curl -u "$GITHUB_USERNAME:$GITHUB_TOKEN" -X POST https://api.github.com/user/repos -d "{\"name\":\"$repo_name\", \"private\": $visibility}"
}

# Get repository name from user
read -p "Enter the desired repository name: " REPO_NAME

# Basic input validation (no spaces or special characters)
if [[ ! "$REPO_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Invalid repository name. Please use only letters, numbers, hyphens, and underscores."
    exit 1
fi

# Create and navigate to repository directory
mkdir -p "$REPO_NAME" && cd "$REPO_NAME"

# Initialize Git repository with main branch
git init -b main

# Create README.md with repository name
echo "# $REPO_NAME" > README.md

# Add initial commit
create_initial_commit

# Create remote repository on GitHub (default: public)
create_remote_repo "$REPO_NAME" false

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
