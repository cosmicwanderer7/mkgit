#!/bin/bash

# Function to prompt for license selection
function prompt_for_license() {
  display_license_menu
  read -erp "Enter the number corresponding to the desired license: " selected_license

  case "$selected_license" in
    1) LICENSE="MIT" ;;
    2) LICENSE="LGPL-3.0" ;;
    3) LICENSE="Apache-2.0" ;;
    4) LICENSE="MPL-2.0" ;;
    5) LICENSE="AGPL-3.0" ;;
    6) LICENSE="Unlicense" ;;
    7) LICENSE="GPL-3.0" ;;
    8) LICENSE="None" ;;
    *)
      echo -e "\e[31mInvalid license selection. Defaulting to None.\e[0m"
      LICENSE="None"
      ;;
  esac
}

# Example function to display license menu (you can replace it with your actual display_license_menu function)
function display_license_menu() {
  echo "License Menu:"
  echo "1) MIT"
  echo "2) LGPL-3.0"
  echo "3) Apache-2.0"
  echo "4) MPL-2.0"
  echo "5) AGPL-3.0"
  echo "6) Unlicense"
  echo "7) GPL-3.0"
  echo "8) None"
}

# Main script
if [ "$LICENSE" = true ]; then
  prompt_for_license
fi
