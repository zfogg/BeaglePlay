#!/bin/bash
# Pull current configurations from running containers on BeaglePlay

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ROOT_DIR="$PROJECT_DIR/root/opt/beagleplay-stack"

echo "Pulling configurations from BeaglePlay..."

# Pull zigbee2mqtt config
echo "  - zigbee2mqtt configuration..."
ssh bp "docker exec zigbee2mqtt cat /app/data/configuration.yaml" > "$ROOT_DIR/zigbee2mqtt/configuration.yaml"

# Pull diyHue configs
echo "  - diyHue configuration..."
ssh bp "docker exec diyhue cat /opt/hue-emulator/config/config.yaml" > "$ROOT_DIR/diyhue/config.yaml"
ssh bp "docker exec diyhue cat /opt/hue-emulator/config/lights.yaml" > "$ROOT_DIR/diyhue/lights.yaml"

# Pull Home Assistant config
echo "  - Home Assistant configuration..."
ssh bp "docker exec homeassistant cat /config/configuration.yaml" > "$ROOT_DIR/homeassistant/configuration.yaml" 2>/dev/null || echo "# Home Assistant configuration" > "$ROOT_DIR/homeassistant/configuration.yaml"

echo ""
echo "Configurations pulled successfully!"
echo "Review changes with: git diff root/"
