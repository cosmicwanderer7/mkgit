#!/bin/bash

# Set a more descriptive error message for missing GitHub CLI
if ! command -v gh &> /dev/null; then
  echo "GitHub CLI (gh) is required for this script. Please install it from https://cli.github.com/."
  exit 1
fi

# Prompt for token only if not already authenticated
if ! gh auth status &> /dev/null; then
  read -rsp "Enter your personal access token (will not be displayed): " token
  gh auth login --with-token "$token"
fi

# Use a single function for both protocol and license selection
function choose_option() {
  local options=("$@")
  local prompt="$1"
  shift
  while true; do
    select opt in "${options[@]}"; do
      echo "Selected $opt"
      return
    done
    echo "Invalid selection. Please choose a valid option."
  done
}

choose_protocol "Select git protocol:" "https" "ssh"
selected_protocol=$REPLY

# Ensure repository name is valid (alphabetic, numeric, hyphens, underscores)
read -p "Enter the name of the repository: " repo_name
if [[ ! "$repo_name" =~ ^[a-zA-Z0-9-_]+$ ]]; then
  echo "Invalid repository name. Please use only letters, numbers, hyphens, and underscores."
  exit 1
fi


read -p "Enter the description of the repository: " repo_description
choose_license "Select a license for the repository:" "MIT" "GNU GPLv3" "Apache License 2.0" "None"
selected_license=$REPLY

gh repo create "$repo_name" --public -y --description="$repo_description" --license="$selected_license"

# Check for successful repository creation before proceeding
if [ $? -ne 0 ]; then
  echo "Failed to create the repository."
  exit 1
fi

# Create a more informative README template
cat > README.md << EOF
# $repo_name

**Description:**
$repo_description

**License:**
$selected_license

**Getting Started:**
(Add instructions for using the repository here)
EOF

# Use 'main' as default branch for consistency
git init
git add README.md
git commit -m "Initial commit with README.md"
git remote add origin "https://github.com/$USER/$repo_name.git"
git push -u origin main

echo "Repository successfully created with README.md and pushed to GitHub!"
