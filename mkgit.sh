#!/bin/bash

# Enable strict error handling
set -euo pipefail

# Configuration file path
CONFIG_FILE="$HOME/.github_config"

# Function to create initial commit
create_initial_commit() {
  git add README.md
  git commit -m "Initial commit: $REPO_NAME"
}

# Function to create remote repository on GitHub
create_remote_repo() {
  local repo_name="$1"
  local visibility="$2" # 'public' or 'private'
  curl -u "$GITHUB_USERNAME:$GITHUB_TOKEN" -X POST https://api.github.com/user/repos \
    -d "{\"name\":\"$repo_name\", \"private\": $visibility}" > /dev/null
}

# Function to prompt for GitHub credentials and save to config file
prompt_github_credentials() {
  echo -e "\e[32mPlease enter your GitHub credentials to set up the script. Your credentials will be saved securely for later use.\e[0m"
  read -erp "GitHub Username: " GITHUB_USERNAME
  read -erp "GitHub Personal Access Token: " GITHUB_TOKEN
  echo -e "\n" # Move to the next line after token input

  # Save credentials to the config file
  echo "GITHUB_USERNAME=\"$GITHUB_USERNAME\"" > "$CONFIG_FILE"
  echo "GITHUB_TOKEN=\"$GITHUB_TOKEN\"" >> "$CONFIG_FILE"
  chmod 600 "$CONFIG_FILE" # Secure file permissions
}

# Function to load GitHub credentials from config file
load_github_credentials() {
  source "$CONFIG_FILE" 2>/dev/null || true
}

# Function to create the Documents/Projects directory
create_projects_directory() {
  local projects_dir="$HOME/Documents/Projects"
  if [ ! -d "$projects_dir" ]; then
    mkdir -p "$projects_dir"
  fi
}

# Check if config file exists, and if not, prompt for credentials
if [ ! -f "$CONFIG_FILE" ]; then
  prompt_github_credentials
fi

# Load GitHub credentials from the config file
load_github_credentials

# Navigate to Documents/Projects directory
cd "$HOME/Documents/Projects" || { echo -e "\e[31mFailed to navigate to Documents/Projects directory. Exiting.\e[0m"; exit 1; }

# Get repository name from user
read -erp "Enter the desired repository name (min 3 characters, letters/numbers/-/_): " REPO_NAME

# Validate repository name
if [[ ! "$REPO_NAME" =~ ^[a-zA-Z0-9_-]+$ || ${#REPO_NAME} -lt 3 ]]; then
  echo -e "\e[31mInvalid repository name. Please use only letters, numbers, hyphens, and underscores (min 3 characters).\e[0m"
  exit 1
fi

# Choose repository visibility (optional)
read -erp "Create a public (1) or private (2) repository? [1]: " visibility
if [[ -z "$visibility" ]]; then visibility=1; fi
case "$visibility" in
  1) visibility="false" ;;
  2) visibility="true" ;;
  *) echo -e "\e[31mInvalid choice. Defaulting to public repository.\e[0m"; visibility="false" ;;
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

# Set repo_path variable
repo_path="$(pwd)"

echo -e "\e[32mSuccessfully created and initialized your Git repository: $REPO_NAME\e[0m"
echo -e "\e[32mYour repository is located at: $repo_path\e[0m"

# Open the repository in a user-defined editor (if available)


if command -v code &>/dev/null; then
  code .
elif command -v nvim &>/dev/null; then
  nvim .
elif command -v sublime &>/dev/null; then
  sublime .
else
  echo -e "\e[31mNo preferred editor detected. Please open the repository manually.\e[0m"
fi

#open repo url in default browser using xdg-open 

repo_url="https://github.com/$GITHUB_USERNAME/$REPO_NAME"
xdg-open "$repo_url" || open "$repo_url" || start "$repo_url"
