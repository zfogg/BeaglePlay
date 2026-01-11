#!/bin/bash
# Stop all containers on BeaglePlay

ssh bp "cd /home/debian/beagleplay-stack && docker-compose down"
echo "All containers stopped!"
