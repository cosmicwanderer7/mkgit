#!/bin/bash

# Enable strict error handling
set -euo pipefail

# Configuration file path
CONFIG_FILE="$HOME/.github_config"

DELETE_FLAG=false
CREATE_IN_CURRENT_DIR=false

# Function to delete the config file
delete_config_file() {
  # Check if the file exists
  if [ -e "$CONFIG_FILE" ]; then
      # Remove the file
      rm "$CONFIG_FILE"
      echo "The $CONFIG_FILE has been deleted."
  else
      echo "The file $CONFIG_FILE does not exist."
  fi
}

# Function to create initial commit
create_initial_commit() {
  git add README.md
  git commit -m "Initial commit"
}

# Function to create remote repository on GitHub
create_remote_repo() {
  local repo_name="$1"
  local visibility="$2" # 'public' or 'private'
  local description="$3"
  curl -u "$GITHUB_USERNAME:$GITHUB_TOKEN" -X POST https://api.github.com/user/repos \
    -d "{\"name\":\"$repo_name\", \"private\": $visibility, \"description\": \"$description\"}" > /dev/null
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

# Function to create Git repository in the current directory
create_git_repo_in_current_dir() {
  git init -b main
  echo "# $(basename "$(pwd)")" > README.md
  create_initial_commit
}

# Parse command line options
while getopts ":di" opt; do
  case $opt in
    d)
      DELETE_FLAG=true
      ;;
    i)
      CREATE_IN_CURRENT_DIR=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# If -d flag is provided, delete the config file and exit
if [ "$DELETE_FLAG" = true ]; then
  delete_config_file
  exit 0
fi

# Check if config file exists, and if not, prompt for credentials
if [ ! -f "$CONFIG_FILE" ]; then
  prompt_github_credentials
fi

# Load GitHub credentials from the config file
load_github_credentials

# Set repository directory
if [ "$CREATE_IN_CURRENT_DIR" = true ]; then
  create_git_repo_in_current_dir
else
  create_projects_directory
  cd "$HOME/Documents/Projects" || { echo -e "\e[31mFailed to navigate to Documents/Projects directory. Exiting.\e[0m"; exit 1; }
fi

# Get repository name and description from user
REPO_NAME=$(basename "$(pwd)")
read -erp "Enter a description for the repository: " REPO_DESCRIPTION

# Create remote repository on GitHub
create_remote_repo "$REPO_NAME" "false" "$REPO_DESCRIPTION"

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

# Open repository URL in default browser using xdg-open
repo_url="https://github.com/$GITHUB_USERNAME/$REPO_NAME"
xdg-open "$repo_url" || open "$repo_url" || start "$repo_url"
