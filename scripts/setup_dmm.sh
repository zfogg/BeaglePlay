#!/bin/bash
# Setup DMM (Zigbee + BLE) on CC1352P7
# This script helps you set up Dynamic Multi-protocol Manager

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
FIRMWARE_DIR="$PROJECT_DIR/assets/firmware"

echo "=== CC1352P7 DMM Setup Helper ==="
echo ""
echo "This will help you set up Zigbee + BLE simultaneously on your BeaglePlay"
echo ""

# Check current setup
echo "📋 Current Configuration:"
echo "  Device: /dev/ttyS1"
echo "  Firmware: Z-Stack 3.x Coordinator (Zigbee only)"
echo "  IEEE: 00:12:4B:00:29:B9:57:27"
echo ""

# Options
echo "DMM Firmware Options:"
echo ""
echo "1. Pre-built Firmware (Recommended for beginners)"
echo "   - Search TI Resource Explorer"
echo "   - Check GitHub: github.com/TexasInstruments/simplelink-dmm-examples"
echo "   - BeagleBoard forums"
echo ""
echo "2. Build from TI SDK (Advanced)"
echo "   - Requires: TI SimpleLink SDK v7.x+"
echo "   - Requires: Code Composer Studio OR command-line tools"
echo "   - Build time: ~30-60 minutes (first time)"
echo ""

# Check for SDK
echo "🔍 Checking for TI SimpleLink SDK..."
if [ -d "/opt/ti/simplelink_cc13xx_cc26xx_sdk" ]; then
    echo "  ✅ Found SDK at /opt/ti/simplelink_cc13xx_cc26xx_sdk"
    SDK_PATH="/opt/ti/simplelink_cc13xx_cc26xx_sdk"
elif [ -d "$HOME/ti/simplelink_cc13xx_cc26xx_sdk" ]; then
    echo "  ✅ Found SDK at $HOME/ti/simplelink_cc13xx_cc26xx_sdk"
    SDK_PATH="$HOME/ti/simplelink_cc13xx_cc26xx_sdk"
else
    echo "  ❌ SDK not found"
    echo ""
    echo "To download TI SimpleLink SDK:"
    echo "  1. Visit: https://www.ti.com/tool/SIMPLELINK-CC13XX-CC26XX-SDK"
    echo "  2. Download SDK for Linux"
    echo "  3. Install to /opt/ti/ or ~/ti/"
    echo ""
    SDK_PATH=""
fi

# Check for firmware files
echo ""
echo "🔍 Checking for firmware files..."
mkdir -p "$FIRMWARE_DIR"

if [ -f "$FIRMWARE_DIR/dmm_zc_ble.hex" ]; then
    echo "  ✅ Found DMM firmware: dmm_zc_ble.hex"
elif [ -f "$FIRMWARE_DIR/CC1352P7_dmm.hex" ]; then
    echo "  ✅ Found DMM firmware: CC1352P7_dmm.hex"
else
    echo "  ❌ No DMM firmware found in $FIRMWARE_DIR"
    echo ""
    echo "Where to find DMM firmware:"
    echo ""
    echo "📦 Option 1: Pre-built from TI"
    echo "   https://dev.ti.com/tirex/explore/content/simplelink_cc13xx_cc26xx_sdk_7_41_00_17/examples/rtos/LP_CC1352P7_1/dmm/dmm_zc_switch_remote_display_app/README.html"
    echo ""
    echo "📦 Option 2: Community Builds"
    echo "   - GitHub: search for 'CC1352P7 DMM firmware'"
    echo "   - BeagleBoard forums: forum.beagleboard.org"
    echo ""
    echo "📦 Option 3: Build yourself"
    if [ -n "$SDK_PATH" ]; then
        echo "   SDK found! Run: $0 --build"
    else
        echo "   First install TI SimpleLink SDK (see above)"
    fi
fi

echo ""
echo "📝 Next Steps:"
echo ""
echo "1. Read the DMM setup guide:"
echo "   cat assets/DMM_SETUP.md"
echo ""
echo "2. Choose your approach:"
echo "   a) Download pre-built DMM firmware → Place in assets/firmware/"
echo "   b) Build from SDK → Run: $0 --build"
echo ""
echo "3. Flash DMM firmware:"
echo "   ./scripts/flash_cc1352_dmm.sh"
echo ""
echo "4. Configure BLE stack:"
echo "   Follow assets/DMM_SETUP.md Phase 4"
echo ""

# Build option
if [ "$1" == "--build" ]; then
    if [ -z "$SDK_PATH" ]; then
        echo "❌ Error: SDK not found. Install TI SimpleLink SDK first."
        exit 1
    fi

    echo ""
    echo "=== Building DMM Firmware ==="
    echo ""

    DMM_EXAMPLE="$SDK_PATH/examples/rtos/LP_CC1352P7_1/dmm/dmm_zc_switch_remote_display_app"

    if [ ! -d "$DMM_EXAMPLE" ]; then
        echo "❌ Error: DMM example not found at $DMM_EXAMPLE"
        exit 1
    fi

    echo "Found DMM example: $DMM_EXAMPLE"
    echo ""
    echo "Building requires Code Composer Studio or command-line tools."
    echo "See TI documentation for build instructions:"
    echo "  $DMM_EXAMPLE/README.html"
    echo ""
fi

echo "For detailed instructions, see: assets/DMM_SETUP.md"
