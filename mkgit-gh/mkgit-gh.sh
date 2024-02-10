#!/bin/bash

# Set error exit code
set -e

# Helper functions

# Check if a command exists
function has_command () {
  command -v "$1" >/dev/null 2>&1
}

# Display usage information
function show_usage () {
  cat << EOF
Usage: $0 [OPTIONS] <repository_name>

Creates a new GitHub repository.

Options:
  -h, --help      Display this help message.
  -p, --private    Create a private repository.
  -l, --license <license> Specify license (MIT, GNU GPLv3, Apache License 2.0, CC BY-SA 4.0, or None).
  -d, --description <description> Provide a description for the repository.

Environment Variables:
  GITHUB_TOKEN  Set your personal access token with repo and gist:create permissions.

Example:
  export GITHUB_TOKEN=your_token
  $0 -p -l MIT my-project
EOF
  exit 0
}

# Parse options and arguments
while getopts ":hpl:d:" opt; do
  case $opt in
    h) show_usage ;;
    p) private=true ;;
    l) license="$OPTARG" ;;
    d) description="$OPTARG" ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

# Validate repository name
repo_name="$1"
if [[ ! "$repo_name" =~ ^[a-zA-Z0-9-_]+$ ]]; then
  echo "Invalid repository name. Use only letters, numbers, hyphens, and underscores."
  exit 1
fi

# Ensure GitHub CLI is available
if ! has_command gh; then
  echo "Error: GitHub CLI (gh) is required. Please install it."
  echo "Download: https://cli.github.com/"
  exit 1
fi

# Check if token is set
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Error: GITHUB_TOKEN environment variable not set."
  echo "Please set it with your personal access token (repo and gist:create permissions)."
  exit 1
fi

# Check if repository exists (using a function for reusability)
function check_repo_exists () {
  if gh api repos/"$repo_name" 2>&1 | grep -q 'Not Found'; then
    echo "Repository doesn't exist. Creating..."
  else
    echo "Repository already exists. Aborting."
    exit 1
  fi
}

check_repo_exists

# Get description if not provided
if [[ -z "$description" ]]; then
  read -p "Enter a description for the repository: " description
fi

# Choose license if not provided
if [[ -z "$license" ]]; then
  choose_license "Select a license (or None):" "MIT" "GNU GPLv3" "Apache License 2.0" "CC BY-SA 4.0" "None"
  license=$REPLY
fi

# Create repository with options
create_opts=""
if [[ $private ]]; then create_opts="$create_opts --private"; fi
if [[ -n "$license" ]]; then create_opts="$create_opts --license=$license"; fi
if [[ -n "$description" ]]; then create_opts="$create_opts --description='$description'"; fi

gh repo create "$repo_name" "$create_opts" -y

# Initialize and setup repository (separate function)
function init_and_setup_repo () {
  mkdir "$repo_name"
  cd "$repo_name"

  cat > README.md << EOF
  # $repo_name

  **Description:**
  $description

  **License:**
  $license

  **Getting Started:**
  (Add instructions for using the repository here)
  EOF

  git init
  git add README.md
  git commit -m "Initial commit with README.md"

  git remote add origin "https://github.com/$USER/$repo_name.git"
  git push -u origin main

  echo "Successfully created '$repo_name' on GitHub with README.md!"
}

init_and_setup_repo
