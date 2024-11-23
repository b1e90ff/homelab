
#!/bin/bash

SERVICE=$1
SSH_USER=$2
SSH_HOST=$3
DEPLOY_PATH=$4

if [ -z "$SERVICE" ] || [ -z "$SSH_USER" ] || [ -z "$SSH_HOST" ] || [ -z "$DEPLOY_PATH" ]; then
    echo "Usage: $0 <service> <ssh_user> <ssh_host> <deploy_path>"
    exit 1
fi

echo "Deploying Docker service: $SERVICE"
echo "sh $SSH_USER@$SSH_HOST 'cd $DEPLOY_PATH/${SERVICE}/. && docker compose pull && docker compose up -d'"
sh $SSH_USER@$SSH_HOST "cd $DEPLOY_PATH/${SERVICE}/. && docker compose pull && docker compose up -d"
echo "WTF"