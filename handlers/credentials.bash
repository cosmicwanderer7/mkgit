#!/bin/bash

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
