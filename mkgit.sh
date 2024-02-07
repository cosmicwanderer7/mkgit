#!/bin/bash

# Enable strict error handling
set -euo pipefail

# Configuration file path
CONFIG_FILE="$HOME/.github_config"

# Function to handle errors with specific error messages
handle_error() {
  local error_message="$1"
  local exit_code="${2:-1}"  # Default exit code is 1 if not provided explicitly
  echo -e "\e[31mError: $error_message\e[0m" >&2  # Print error message to stderr
  exit "$exit_code"
}

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
    rm "$CONFIG_FILE" || handle_error "Failed to delete the config file: $CONFIG_FILE."
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

  local response
  response=$(curl -s -u "$GITHUB_USERNAME:$GITHUB_TOKEN" -X POST https://api.github.com/user/repos \
    -d "{\"name\":\"$repo_name\", \"private\": $visibility, \"description\": \"$description\", \"license_template\": \"$license\"}")

  if [[ $response == *"\"id\""* ]]; then
    echo "Repository '$repo_name' created successfully on GitHub."
  else
    handle_error "Failed to create remote repository on GitHub. Response: $response"
  fi
}

# Function to prompt for GitHub credentials and save to config file
prompt_github_credentials() {
  echo -e "\e[32mPlease enter your GitHub credentials to set up the script. Your credentials will be saved securely for later use.\e[0m"
  read -erp "GitHub Username: " GITHUB_USERNAME
  read -erp "GitHub Personal Access Token: " GITHUB_TOKEN
  echo -e "\n" # Move to the next line after token input

  # Save credentials to the config file
  echo "GITHUB_USERNAME=\"$GITHUB_USERNAME\"" > "$CONFIG_FILE" || handle_error "Failed to save GitHub username to config file."
  echo "GITHUB_TOKEN=\"$GITHUB_TOKEN\"" >> "$CONFIG_FILE" || handle_error "Failed to save GitHub token to config file."
  chmod 600 "$CONFIG_FILE" || handle_error "Failed to set permissions for the config file: $CONFIG_FILE."
}

# Function to load GitHub credentials from config file
load_github_credentials() {
  source "$CONFIG_FILE" 2>/dev/null || handle_error "Failed to load GitHub credentials from config file: $CONFIG_FILE."
}

# Function to create the Documents/Projects directory
create_projects_directory() {
  local projects_dir="$HOME/Documents/Projects"
  if [ ! -d "$projects_dir" ]; then
    mkdir -p "$projects_dir" || handle_error "Failed to create Documents/Projects directory."
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
  cd "$HOME/Documents/Projects" || handle_error "Failed to navigate to Documents/Projects directory."

  # Get repository name and description from user (skip if INITIALIZE_REPO=true)
  if [ "$INITIALIZE_REPO" != true ]; then
    read -erp "Enter the desired repository name (min 3 characters, letters/numbers/-/_): " REPO_NAME
  fi
  read -erp "Enter a description for the repository: " REPO_DESCRIPTION

  # Validate repository name
  if [[ ! "$REPO_NAME" =~ ^[a-zA-Z0-9_-]+$ || ${#REPO_NAME} -lt 3 ]]; then
    handle_error "Invalid repository name. Please use only letters, numbers, hyphens, and underscores (min 3 characters)."
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
  else
    LICENSE="None"  # Default to no license if -l flag is not provided
  fi

  # Choose repository visibility (optional)
  read -erp "Create a public (1) or private (2) repository? [1]: " visibility
  if [[ -z "$visibility" ]]; then visibility=1; fi
  case "$visibility" in
    1) visibility="false" ;;
    2) visibility="true" ;;
    *) handle_error "Invalid choice. Defaulting to public repository." ;;
  esac

  # Create and navigate to repository directory
  mkdir -p "$REPO_NAME" && cd "$REPO_NAME" || handle_error "Failed to create repository directory."

  # Initialize Git repository with main branch
  git init -b main || handle_error "Failed to initialize Git repository."

  # Create README.md with repository name
  echo "# $REPO_NAME" > README.md

  # Add initial commit
  git add README.md
  git commit -m "Initial commit: $REPO_NAME" || handle_error "Failed to commit changes."

  # Create remote repository on GitHub
  create_remote_repo "$REPO_NAME" "$visibility" "$REPO_DESCRIPTION" "$LICENSE"

  # Add remote and push initial commit
  git remote add origin "git@github.com:$GITHUB_USERNAME/$REPO_NAME.git" || handle_error "Failed to add remote repository."

  if [ "$LICENSE" = true ]; then
    git pull --rebase origin main && git push -u origin main || handle_error "Failed to push changes to remote repository."
  else
    git push -u origin main || handle_error "Failed to push changes to remote repository."
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
      handle_error "Invalid option: -$OPTARG"  # Use handle_error function for unknown options
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
