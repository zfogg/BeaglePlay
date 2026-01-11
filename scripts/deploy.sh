#!/bin/bash
# Deploy BeaglePlay home automation stack to the device

set -e

REMOTE_USER="debian"
REMOTE_HOST="bp"
DEPLOY_DIR="/home/debian/beagleplay-stack"

echo "Deploying to $REMOTE_USER@$REMOTE_HOST"
echo ""

# Create deployment directory
ssh "$REMOTE_USER@$REMOTE_HOST" "mkdir -p $DEPLOY_DIR"

# Deploy docker-compose.yml to home directory
echo "Deploying docker-compose.yml..."
rsync -av docker-compose.yml "$REMOTE_USER@$REMOTE_HOST:$DEPLOY_DIR/"

# Deploy root/ contents to / (requires sudo)
echo "Deploying configuration files to /opt/beagleplay-stack..."
rsync -av --rsync-path="sudo rsync" root/ "$REMOTE_USER@$REMOTE_HOST:/"

echo ""
echo "Deployment complete!"
echo ""
echo "Next steps:"
echo "  1. Start the stack: ./scripts/start.sh"
echo "  2. View logs:       ./scripts/logs.sh <service>"
echo "  3. Stop the stack:  ./scripts/stop.sh"
