#!/bin/bash

# Set script exit code to 0 initially
set -e

# Check for GitHub CLI
if ! command -v gh &> /dev/null; then
  echo "Error: GitHub CLI (gh) is required. Install it from your distro package manager or https://cli.github.com/"
  exit 1
fi

# Print usage with -h or --help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  cat << EOF
Usage: $0 [OPTIONS] <repository_name>

Creates a new GitHub repository with a README template.

Options:
  -h, --help      Display this help message.
  -p, --private   Create a private repository.
  -l, --license   Specify license (MIT, GNU GPLv3, Apache 2.0, CC BY-SA 4.0, or None).
  -d, --description Provide a description for the repository.

Environment Variables:
  GITHUB_TOKEN  Set your personal access token with repo and gist:create permissions.

Example:
  export GITHUB_TOKEN=your_token
  $0 -p -l MIT my-project
EOF
  exit 0
fi

# Parse options and arguments
private=false
license=""
description=""
while getopts ":hpl:d:" opt; do
  case $opt in
    h) ;;
    p) private=true ;;
    l) license="$OPTARG" ;;
    d) description="$OPTARG" ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

# Validate repository name
repo_name="$1"
if [[ ! "<span class="math-inline">repo\_name" \=\~ ^\[a\-zA\-Z0\-9\-\_\]\+</span> ]]; then
  echo "Invalid repository name. Use only letters, numbers, hyphens, and underscores."
  exit 1
fi

# Check if repository already exists using gh api
if gh api repos/"$repo_name" 2>&1 | grep -q 'Not Found'; then
  echo "Repository doesn't exist. Creating..."
else
  echo "Repository already exists. Aborting."
  exit 1
fi

# Get description if not provided with -d
if [[ -z "$description" ]]; then
  read -p "Enter a description for the repository: " description
fi

# Choose license if not provided with -l
if [[ -z "$license" ]]; then
  # Define license choices with descriptions for clarity
  choices=("MIT (Open-source permissive license)" "GNU GPLv3 (Copyleft, strong copyleft)" "Apache License 2.0 (Permissive license)" "CC BY-SA 4.0 (Creative Commons, attribution & share-alike)" "None")
  prompt="Select a license (or None):"
  # Offer interactive or user-guided license selection (as applicable)
  # ...

  license=$REPLY
fi

# Create repository with options
create_opts=""
if [[ $private ]]; then
  create_opts="$create_opts --private"
fi
if [[ -n "$license" ]]; then
  create_opts="$create_opts --license=$license"
fi
if [[ -n "$description" ]]; then
  create_opts="$create_opts --description='$description'"
fi

# Validate GITHUB_TOKEN
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Error: GITHUB_TOKEN environment variable not set. Set it with your personal access token (repo and gist:create permissions) before running the script."
  exit 1
fi

# Create repository on GitHub
gh repo create "$repo_name" $create_opts -y

echo "Successfully created '$repo_name' on GitHub!"

# Create the repo directory locally (optional)
# Uncomment and customize if desired
# mkdir "$repo_name"
# cd "$repo_name"

# Create informative README template
cat > README.md << EOF
# $repo_name

**Description:**

$description

**License:**

$license

**Getting Started:**

(Add instructions for using the repository here)

**Additional Notes:**

* You can find more information about the project in the following files (if appropriate):
    *

