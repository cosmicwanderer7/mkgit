#!/bin/bash

# TO-DO: try to pass parameters as much as possible to functions rather than using global variables

# Enable strict error handling
set -euo pipefail

# Configuration file path
CONFIG_FILE="$HOME/.github_config"

DELETE_FLAG=false
INITIALIZE_REPO=false
LICENSE=""
HELP_FLAG=false

# utils
source "$(dirname "$0")/utils/display.bash"
source "$(dirname "$0")/utils/file_handling.bash"
source "$(dirname "$0")/utils/prompt.bash"
# handlers
source "$(dirname "$0")/handlers/git_init.bash"
source "$(dirname "$0")/handlers/credentials.bash"
source "$(dirname "$0")/handlers/repo.bash"

# Main functionality
main() {
  # Check if config file exists, and if not, prompt for credentials
  if [ ! -f "$CONFIG_FILE" ]; then
    prompt_github_credentials
  fi

  # Load GitHub credentials from the config file
  source "$CONFIG_FILE" 2>/dev/null || true

  # Navigate to Documents/Projects directory
  cd "$HOME/Documents/Projects" || { echo -e "\e[31mFailed to navigate to Documents/Projects directory. Exiting.\e[0m"; exit 1; }

  # Get repository name and description from user
  # Get repository name and description from user (skip if INITIALIZE_REPO=true)
 if [ "$INITIALIZE_REPO" != true ]; then
  while true; do
    read -erp "Enter the desired repository name (min 3 characters, letters/numbers/-/_): " REPO_NAME

    if [[ ! "$REPO_NAME" =~ ^[a-zA-Z0-9_-]+$ || ${#REPO_NAME} -lt 3 ]]; then
      echo -e "\e[31mInvalid repository name. Please use only letters, numbers, hyphens, and underscores (min 3 characters).\e[0m"
    else
      break
    fi
  done
fi

read -erp "Enter a description for the repository: " REPO_DESCRIPTION

# If -l flag is provided, prompt for license selection
if [ "$LICENSE" = true ]; then
  prompt_for_license
fi

read -erp "Create a public(1) or private(2) repository? [default=1]: " visibility
if [[ -z "$visibility" ]]; then visibility=1; fi
case "$visibility" in
  1) visibility="false" ;;
  2) visibility="true" ;;
  *) visibility="false" ;;
esac

  git_init

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
