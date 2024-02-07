#!/bin/bash

# Enable strict error handling
set -euo pipefail

# Configuration file path
CONFIG_FILE="$HOME/.github_config"

DELETE_FLAG=false
INITIALIZE_REPO=false
LICENSE=""
HELP_FLAG=false

# Function to display help message
display_help() {
  echo -e "Usage: $0 [-d] [-i] [-l] [-h]\n"
  echo "Options:"
  echo "  -d   Delete the configuration file and exit."
  echo "  -i   Initialize a Git repository in the current directory."
  echo "  -l   Prompt for license selection."
  echo "  -h   Display this help message."
  exit 0
}

# Function to delete the config file
delete_config_file() {
  if [ -e "$CONFIG_FILE" ]; then
    rm "$CONFIG_FILE"
    echo "The $CONFIG_FILE has been deleted."
  else
    echo "The file $CONFIG_FILE does not exist."
  fi
}

# Function to create remote repository on GitHub
create_remote_repo() {
  local repo_name="$1"
  local visibility="$2"
  local description="$3"
  local license="$4"

  curl -u "$GITHUB_USERNAME:$GITHUB_TOKEN" -X POST https://api.github.com/user/repos \
    -d "{\"name\":\"$repo_name\", \"private\": $visibility, \"description\": \"$description\", \"license_template\": \"$license\"}" > /dev/null
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

# Function to display license menu
display_license_menu() {
  echo "Select a license:"
  echo "1. MIT"
  echo "2. LGPL 3.0"
  echo "3. Apache 2.0"
  echo "4. MPL 2.0"
  echo "5. AGPL 3.0"
  echo "6. Unlicense"
  echo "7. GPL-3.0"
  echo "8. None" 
}

# Main functionality
main() {
  # Check if config file exists, and if not, prompt for credentials
  if [ ! -f "$CONFIG_FILE" ]; then
    prompt_github_credentials
  fi

  # Load GitHub credentials from the config file
  load_github_credentials

  # Navigate to Documents/Projects directory
  cd "$HOME/Documents/Projects" || { echo -e "\e[31mFailed to navigate to Documents/Projects directory. Exiting.\e[0m"; exit 1; }

  # Get repository name and description from user
  # Get repository name and description from user (skip if INITIALIZE_REPO=true)
  if [ "$INITIALIZE_REPO" != true ]; then
    read -erp "Enter the desired repository name (min 3 characters, letters/numbers/-/_): " REPO_NAME
  fi

  read -erp "Enter a description for the repository: " REPO_DESCRIPTION

  # Validate repository name
  if [[ ! "$REPO_NAME" =~ ^[a-zA-Z0-9_-]+$ || ${#REPO_NAME} -lt 3 ]]; then
    echo -e "\e[31mInvalid repository name. Please use only letters, numbers, hyphens, and underscores (min 3 characters).\e[0m"
    exit 1
  fi

  # If -l flag is provided, prompt for license selection
  if [ "$LICENSE" = true ]; then
    display_license_menu
    read -erp "Enter the number corresponding to the desired license: " selected_license

    case "$selected_license" in
      1) LICENSE="MIT" ;;
      2) LICENSE="LGPL-3.0" ;;
      3) LICENSE="Apache-2.0" ;;
      4) LICENSE="MPL-2.0" ;;
      5) LICENSE="AGPL-3.0" ;;
      6) LICENSE="Unlicense" ;;
      7) LICENSE="GPL-3.0";;
      8) LICENSE="None";;
      *)
        echo -e "\e[31mInvalid license selection. Defaulting to None.\e[0m"
        LICENSE="None"
        ;;
    esac
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
  # Set repo_path variable
  repo_path="$(pwd)"

  echo -e "\e[32mSuccessfully created and initialized your Git repository: $REPO_NAME\e[0m"
  echo -e "\e[32mYour repository is located at: $repo_path\e[0m"
}

# Parse command line options
while getopts ":dilh" opt; do
  case $opt in
    d)
      DELETE_FLAG=true
      ;;
    i)
      INITIALIZE_REPO=true
      ;;
    l)
      LICENSE=true
      ;;
    h)
      HELP_FLAG=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Display help message if -h flag is provided
if [ "$HELP_FLAG" = true ]; then
  display_help
fi

# If -d flag is provided, delete the config file and exit
if [ "$DELETE_FLAG" = true ]; then
  delete_config_file
  exit 0
fi

# Execute the main functionality
main
