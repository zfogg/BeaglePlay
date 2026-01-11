#!/bin/bash
# Start all containers on BeaglePlay

set -e

ssh bp "cd /home/debian/beagleplay-stack && docker-compose up -d"

echo "All containers started!"
echo ""
echo "Services:"
echo "  - Mosquitto MQTT:  localhost:1883"
echo "  - Zigbee2MQTT UI:  http://bp:8080"
echo "  - diyHue Bridge:   http://bp (port 80)"
echo "  - Home Assistant:  http://bp:8123"
echo ""
echo "View logs with: ./scripts/logs.sh <service>"
