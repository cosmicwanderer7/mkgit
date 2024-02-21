#!/bin/bash


# Function to delete the config file
delete_config_file() {
  if [ -e "$CONFIG_FILE" ]; then
    rm "$CONFIG_FILE"
    echo "The $CONFIG_FILE has been deleted."
  else
    echo "The file $CONFIG_FILE does not exist."
  fi
}

# Function to create the Documents/Projects directory
create_projects_directory() {
  local projects_dir="$HOME/Documents/Projects"
  if [ ! -d "$projects_dir" ]; then
    mkdir -p "$projects_dir"
  fi
}
