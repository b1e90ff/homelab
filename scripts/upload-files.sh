#!/bin/bash

SERVICE=$1
SSH_USER=$2
SSH_HOST=$3
DEPLOY_PATH=$4

if [ -z "$SERVICE" ] || [ -z "$SSH_USER" ] || [ -z "$SSH_HOST" ] || [ -z "$DEPLOY_PATH" ]; then
    echo "Usage: $0 <service> <ssh_user> <ssh_host> <deploy_path>"
    exit 1
fi

# Create data directory structure
echo "Creating data directory for $SERVICE"
ssh $SSH_USER@$SSH_HOST "mkdir -p $DEPLOY_PATH/../data/$SERVICE"

echo "Processing secrets in yaml files for $SERVICE"
./scripts/replace-secrets.sh "$SERVICE" "$DEPLOY_PATH"
ls -la "$SERVICE"

echo "Uploading $SERVICE"
rsync -av --include=".*" --delete "${SERVICE}/" $SSH_USER@$SSH_HOST:$DEPLOY_PATH/${SERVICE}/