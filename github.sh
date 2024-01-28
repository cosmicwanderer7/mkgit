#!/bin/bash

# Enable strict error handling
set -euo pipefail

# GitHub credentials (replace with your actual values)
export GITHUB_USERNAME="your_usrname"
export GITHUB_TOKEN="your_github_token"

# Function to create initial commit
create_initial_commit() {
  git add README.md
  git commit -m "Initial commit: $REPO_NAME"
}

# Function to create remote repository on GitHub
create_remote_repo() {
  local repo_name="$1"
  local visibility="$2" # 'public' or 'private'
  curl -u "$GITHUB_USERNAME:$GITHUB_TOKEN" -X POST https://api.github.com/user/repos \ -d "{\"name\":\"$repo_name\", \"private\": $visibility}"
}

# Get repository name from user
read -p "Enter the desired repository name (min 3 characters, letters/numbers/-/_): " REPO_NAME

# Validate repository name
if [[ ! "$REPO_NAME" =~ ^[a-zA-Z0-9_-]+$ || ${#REPO_NAME} -lt 3 ]]; then
  echo "Invalid repository name. Please use only letters, numbers, hyphens, and underscores (min 3 characters)."
  exit 1
fi

# Choose repository visibility (optional)
read -p "Create a public (1) or private (2) repository? [1]: " visibility
if [[ -z "$visibility" ]]; then visibility=1; fi
case "$visibility" in
  1) visibility="false" ;;
  2) visibility="true" ;;
  *) echo "Invalid choice. Defaulting to public repository."; visibility="false" ;;
esac

# Create and navigate to repository directory
mkdir -p "$REPO_NAME" && cd "$REPO_NAME"

# Initialize Git repository with main branch
git init -b main

# Create README.md with repository name
echo "# $REPO_NAME" > README.md

# Add initial commit
create_initial_commit

# Create remote repository on GitHub
create_remote_repo "$REPO_NAME" "$visibility"

# Add remote and push initial commit
git remote add origin "git@github.com:$GITHUB_USERNAME/$REPO_NAME.git"
git push -u origin main

# Open the repository in a user-defined editor (if available)
editor=""
if command -v code &>/dev/null; then editor="code"; fi
elif command -v nvim &>/dev/null; then editor="nvim"; fi
elif command -v sublime &>/dev/null; then editor="sublime"; fi
if [[ -n "$editor" ]]; then
  "$editor" .
else
  echo "No preferred editor detected. Please open the repository manually."
fi

echo "Successfully created and initialized your Git repository: $REPO_NAME!"
