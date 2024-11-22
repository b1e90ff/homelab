#!/bin/bash

SERVICE=$1
DEPLOY_PATH=$2

if [ -z "$SERVICE" ] || [ -z "$DEPLOY_PATH" ]; then
    echo "Usage: $0 <service> <deploy_path>"
    exit 1
fi

# Track if we found any missing secrets
missing_secrets=false
# Array to collect missing secret names
declare -a missing_secret_list

# Find all yaml/yml files recursively (excluding docker-compose files and logs)
find "${SERVICE}" -type f \( -name "*.yml" -o -name "*.yaml" \) ! -name "docker-compose.*" ! -path "*/\.*/*" ! -path "*/logs/*" ! -path "*/log/*" -print0 | while IFS= read -r -d '' file; do
    echo "Checking file: $file"
    
    # Create temporary file
    temp_file=$(mktemp)
    
    # Read the file line by line
    while IFS= read -r line; do
        # Check if line contains ${SECRET_*} pattern
        if echo "$line" | grep -q '\${SECRET_[^}]*}'; then
            # Extract the secret name without SECRET_ prefix
            secret_name=$(echo "$line" | grep -o '\${SECRET_[^}]*}' | sed 's/\${SECRET_\(.*\)}/\1/')
            
            # Get corresponding environment variable without SECRET_ prefix
            env_var_name=$(echo "$secret_name")
            env_var_value=${!env_var_name}
            
            if [ ! -z "$env_var_value" ]; then
                # Replace ${SECRET_VAR} with actual value
                echo "$line" | sed "s/\${SECRET_${secret_name}}/${env_var_value}/" >> "$temp_file"
            else
                echo "Error: Required secret $env_var_name not found!"
                missing_secrets=true
                # Add to missing secrets list if not already present
                if [[ ! " ${missing_secret_list[@]} " =~ " ${env_var_name} " ]]; then
                    missing_secret_list+=("$env_var_name")
                fi
                echo "$line" >> "$temp_file"
            fi
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$file"
    
    # Replace original file with modified content
    mv "$temp_file" "$file"
done

# Check if any secrets were missing and display them
if [ "$missing_secrets" = true ]; then
    echo -e "\nError: The following secrets are missing:"
    printf '%s\n' "${missing_secret_list[@]}"
    exit 1
fi