#!/bin/bash

SERVICE=$1
DEPLOY_PATH=$2

if [ -z "$SERVICE" ] || [ -z "$DEPLOY_PATH" ]; then
    echo "Usage: $0 <service> <deploy_path>"
    exit 1
fi

# Find all yaml files and process them
find "${SERVICE}" -type f \( -name "*.yml" -o -name "*.yaml" \) ! -name "docker-compose.*" ! -path "*/\.*/*" ! -path "*/logs/*" -print0 | while IFS= read -r -d '' file; do
    echo "Processing: $file"
    
    # Get all SECRET_ variables and replace them
    grep -o '\${SECRET_[^}]*}' "$file" | sort -u | while read -r secret; do
        var_name=$(echo "$secret" | sed 's/\${SECRET_\(.*\)}/\1/')
        var_value=${!var_name}
        
        if [ -z "$var_value" ]; then
            echo "Error: Missing secret $var_name"
            exit 1
        fi
        
        sed -i "s|${secret}|${var_value}|g" "$file"
    done
done