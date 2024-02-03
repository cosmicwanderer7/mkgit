#!/bin/bash

# Set script exit code to 0 initially
set -e

# Check for GitHub CLI
if ! command -v gh &> /dev/null; then
  echo "Error: GitHub CLI (gh) is required. Please install it from https://cli.github.com/."
  exit 1
fi

# Check authentication and get token if needed
if ! gh auth status &> /dev/null; then
  echo "Authentication required. Visit https://github.com/settings/tokens to create a personal access token with repo and gist: create permissions."
  read -rsp "Enter your personal access token (will not be displayed): " token
  gh auth login --with-token "$token"
fi

# Function for protocol and license selection
function choose_option() {
  local prompt="$1"
  shift
  while true; do
    select opt in "$@"; do
      echo "Selected: $opt"
      return
    done
    echo "Invalid selection. Please choose a valid option."
  done
}

# Choose protocol
choose_protocol "Select git protocol:" "https" "ssh"
selected_protocol=$REPLY

# Check for valid repository name
read -p "Enter the desired repository name (alphanumeric, hyphens, underscores): " repo_name
if [[ ! "$repo_name" =~ ^[a-zA-Z0-9-_]+$ ]]; then
  echo "Invalid name. Use only letters, numbers, hyphens, and underscores."
  exit 1
fi

# Check if repository already exists using gh api
if gh api repos/"$repo_name" 2>&1 | grep -q 'Not Found'; then
  echo "Repository doesn't exist. Creating..."
else
  echo "Repository already exists. Aborting."
  exit 1
fi

# Get description and license
read -p "Enter a description for the repository: " repo_description
choose_license "Select a license (or None):" "MIT" "GNU GPLv3" "Apache License 2.0" "None"
selected_license=$REPLY

# Create repository with selected options
gh repo create "$repo_name" --public -y --description="$repo_description" --license="$selected_license"

# Create informative README template
cat > README.md << EOF
# $repo_name

**Description:**
$repo_description

**License:**
$selected_license

**Getting Started:**
(Add instructions for using the repository here)
EOF

# Initialize git, add and commit README
git init
git add README.md
git commit -m "Initial commit with README.md"

# Set remote origin and push to GitHub
git remote add origin "https://github.com/$USER/$repo_name.git"
git push -u origin main

echo "Successfully created '$repo_name' on GitHub with README.md!"
