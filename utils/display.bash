#!/bin/bash

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
