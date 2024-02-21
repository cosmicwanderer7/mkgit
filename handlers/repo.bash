#!/bin/bash

# Function to create remote repository on GitHub
create_remote_repo() {
  local repo_name="$1"
  local visibility="$2"
  local description="$3"
  local license="$4"

  curl -u "$GITHUB_USERNAME:$GITHUB_TOKEN" -X POST https://api.github.com/user/repos \
    -d "{\"name\":\"$repo_name\", \"private\": $visibility, \"description\": \"$description\", \"license_template\": \"$license\"}" > /dev/null
}

