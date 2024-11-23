
#!/bin/bash

SERVICE=$1
SSH_USER=$2
SSH_HOST=$3
DEPLOY_PATH=$4

if [ -z "$SERVICE" ] || [ -z "$SSH_USER" ] || [ -z "$SSH_HOST" ] || [ -z "$DEPLOY_PATH" ]; then
    echo "Usage: $0 <service> <ssh_user> <ssh_host> <deploy_path>"
    exit 1
fi

# Create remote directory
ssh $SSH_USER@$SSH_HOST "mkdir -p $DEPLOY_PATH/${SERVICE}"

# Check if service has secrets
if yq eval ".services.${SERVICE}" secrets.yml > /dev/null 2>&1; then
    # Build env file content from environment variables
    env_content=""
    while read -r secret_name; do
        secret_value=${!secret_name}
        if [ ! -z "$secret_value" ]; then
            env_content+="${secret_name}='${secret_value}'"$'\n'
        fi
    done < <(yq eval ".services.${SERVICE}.secrets[]" secrets.yml)
    
    # Upload env content
    echo "$env_content" | ssh $SSH_USER@$SSH_HOST "cat > $DEPLOY_PATH/${SERVICE}/.env"
    echo "Created .env file for $SERVICE"
else
    echo "No secrets defined for $SERVICE"
fi