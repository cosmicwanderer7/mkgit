#!/bin/bash

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    exit 1
fi

# Enter Github Personal Access Token 
read -p "Enter your personal access token :" token

# Function to display a list of available licenses and prompt user to select one
choose_protocol() {
    echo "Select git protocol:"
    select protocol in "https" "ssh"; do
        case $protocol in
            https|ssh)
                echo "Selected Protocol: $protocol"
                selected_protocol="$protocol"
                break
                ;;
            *)
                echo "Invalid selection. Please choose a valid protocol."
                ;;
        esac
    done
}



# Check if GitHub CLI is already authenticated
if ! gh auth status &> /dev/null; then
    echo "You are not authenticated. Please log in."
    gh auth login --git-protocol $protocol --with-token $token
fi

# Function to display a list of available licenses and prompt user to select one
choose_license() {
    echo "Select a license for the repository:"
    select license in "MIT" "GNU GPLv3" "Apache License 2.0" "None"; do
        case $license in
            MIT|GNU\ GPLv3|Apache\ License\ 2.0|None)
                echo "Selected license: $license"
                selected_license="$license"
                break
                ;;
            *)
                echo "Invalid selection. Please choose a valid license."
                ;;
        esac
    done
}

# Get repository name from user
read -p "Enter the name of the repository: " repo_name

# Check if the repository name is provided
if [ -z "$repo_name" ]; then
    echo "Repository name cannot be empty."
    exit 1
fi

# Check if the repository name contains spaces
if [[ "$repo_name" =~ [[:space:]] ]]; then
    echo "Repository name cannot contain spaces."
    exit 1
fi

# Check if the repository already exists on GitHub
gh_repo_check=$(gh repo view "$repo_name" 2>&1)
if [[ $gh_repo_check == *"Not Found"* ]]; then
    echo "Repository does not exist on GitHub. Creating a new one..."
else
    echo "Repository already exists on GitHub. Aborting."
    exit 1
fi

# Get repository description from user
read -p "Enter the description of the repository: " repo_description

# Choose a license
choose_license

# Create the repository with selected license if applicable
if [ "$selected_license" != "None" ]; then
    gh repo create $repo_name --public -y --description="$repo_description" --license="$selected_license"
else
    gh repo create $repo_name --public -y --description="$repo_description"
fi

# Check if the repository creation was successful
if [ $? -ne 0 ]; then
    echo "Failed to create the repository."
    exit 1
fi

# Initialize a git repository
git init

# Create README.md file
echo "# $repo_name" > README.md
echo "This is the README file for the $repo_name repository." >> README.md

# Add README.md file
git add README.md

# Commit changes
git commit -m "Add README.md"

# Set the remote origin
git remote add origin "https://github.com/yourusername/$repo_name.git"

# Push changes to the remote repository
git push -u origin master

echo "Repository successfully created with README.md and pushed to GitHub."
