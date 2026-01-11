#!/bin/bash
# Watch Zigbee2MQTT logs for device joining

echo "Watching for Zigbee devices joining..."
echo "Press Ctrl+C to stop"
echo ""

ssh bp "docker logs -f zigbee2mqtt 2>&1" | grep --line-buffered -iE 'interview|join|device|philips|0x[0-9a-f]{16}|successfully'
