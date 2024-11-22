#!/bin/bash

SERVICE=$1
SSH_USER=$2
SSH_HOST=$3
DEPLOY_PATH=$4

if [ -z "$SERVICE" ] || [ -z "$SSH_USER" ] || [ -z "$SSH_HOST" ] || [ -z "$DEPLOY_PATH" ]; then
    echo "Usage: $0 <service> <ssh_user> <ssh_host> <deploy_path>"
    exit 1
fi

echo "Processing secrets in yaml files for $SERVICE"
./scripts/replace-secrets.sh "$SERVICE" "$DEPLOY_PATH"

echo "Uploading $SERVICE"
scp -r "${SERVICE}" $SSH_USER@$SSH_HOST:$DEPLOY_PATH/