#!/bin/bash
# View logs from containers on BeaglePlay

SERVICE="${1:-}"

if [ -z "$SERVICE" ]; then
    echo "Usage: $0 <service>"
    echo ""
    echo "Available services:"
    echo "  - mosquitto"
    echo "  - zigbee2mqtt"
    echo "  - diyhue"
    echo "  - homeassistant"
    exit 1
fi

ssh bp "docker logs -f $SERVICE"
