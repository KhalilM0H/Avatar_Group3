#!/bin/bash

# Author: Guy Buhendwa
# Ensure the data directory exists
mkdir -p data

# Function to rename files sequentially
rename_files_sequentially() {
  category="$1"
  counter=1
  for file in "$category"/*; do
    if [ -f "$file" ]; then
      extension="${file##*.}"
      mv "$file" "$category/$counter.$extension"
      counter=$((counter + 1))
    fi
  done
}

# Function to unify files and change timestamps
unify_and_change_timestamp() {
  category="$1"
  unified_dir="$category/Unified"
  mkdir -p "$unified_dir"

  # Unify files
  find "$category" -type f -exec mv {} "$unified_dir" \;

  # Change timestamps
  for file in "$unified_dir"/*; do
    if [ -f "$file" ]; then
      random_days=$((RANDOM % 10))
      random_timestamp=$(date -d "$random_days days ago" +"%Y%m%d%H%M.%S")
      touch -t "$random_timestamp" "$file"
    fi
  done
}

# Main script
data_zip="data.zip"  # Specify the name of your zip file

# Extract the zip file
unzip "$data_zip" -d data

while IFS= read -r line; do
  category=$(echo "$line" | awk '{print $1}')  # Extract the category from the line
  action=$(echo "$line" | awk '{print $2}')    # Extract the action from the line

  if [ "$action" == ">>" ]; then
    mkdir -p "data/$category"
  elif [ "$action" == "takeoff" ]; then
    rename_files_sequentially "data/$category"
  elif [ "$action" == "unify" ]; then
    unify_and_change_timestamp "data/$category"
  fi
done < "data/data.txt"

# Display files before and after changes
echo "Files before renaming and timestamp change:"
find data -type f -exec ls -l {} \;

echo "Files after renaming and timestamp change:"
find data -type f -exec ls -l {} \;

