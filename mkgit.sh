#!/bin/bash

# Enable strict error handling
set -euo pipefail

# GitHub credentials (replace with your actual values)

export GITHUB_USERNAME="your_github_username"
export GITHUB_TOKEN="your_github_token"


###########################################################################
## Function Name : create_initial_commit                                 ##
## Description : Adds a README.md in the repository created and create   ##
##               the initial commit in the repository                    ##
###########################################################################
create_initial_commit() {
  git add README.md
  git commit -m "Initial commit: $REPO_NAME"
}

###########################################################################
## Function Name : create_remote_repo                                    ##
## Description : Create a remote repository on Github using the Github   ##
##               API with the provided repository name and visibility    ##
## Arguments : $1 - Repository Name                                      ##
##             $2 - Visiblity (public/private)                           ##
###########################################################################

create_remote_repo() {
  local repo_name="$1"
  local visibility="$2" # 'public' or 'private'
  curl -u "$GITHUB_USERNAME:$GITHUB_TOKEN" -X POST https://api.github.com/user/repos \ -d "{\"name\":\"$repo_name\", \"private\": $visibility}"
}

###########################################################################
## Function Name : get_repo_name                                         ##
## Description : Prompt the user to enter the desired repository name    ##
##               with input validation.                                  ##
###########################################################################

get_repo_name() { 
  read -p "Enter the desired repository name (min 3 characters, letters/numbers/-/_): " REPO_NAME

  # Validate repository name
  if [[ ! "$REPO_NAME" =~ ^[a-zA-Z0-9_-]+$ || ${#REPO_NAME} -lt 3 ]]; then
    echo "Invalid repository name. Please use only letters, numbers, hyphens, and underscores (min 3 characters)."
    exit 1
  fi
}


# Choose repository visibility (optional)
read -p "Create a public (1) or private (2) repository? [1]: " visibility
if [[ -z "$visibility" ]]; then visibility=1; fi
case "$visibility" in
  1) visibility="false" ;;
  2) visibility="true" ;;
  *) echo "Invalid choice. Defaulting to public repository."; visibility="false" ;;
esac

# Get repo name
get_repo_name

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
if command -v code &>/dev/null; then #failsafe
  code .
elif command -v nvim &>/dev/null; then #failsafe
  nvim .
elif command -v sublime &>/dev/null; then #failsafe
  sublime .
else
  echo -e "\e[31mNo preferred editor detected. Please open the repository manually.\e[0m"
fi

echo "Successfully created and initialized your Git repository: $REPO_NAME!"
