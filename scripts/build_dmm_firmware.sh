#!/bin/bash
# Automated DMM firmware build script for CC1352P7

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
FIRMWARE_DIR="$PROJECT_DIR/assets/firmware"
DOWNLOAD_DIR="$HOME/Downloads/ti-sdk"

# Configuration - try multiple SDK versions
SDK_VERSIONS=("8_30_01_01" "8_32_00_07" "7_41_00_17")
DMM_EXAMPLE="dmm_zc_switch_remote_display_app"
TARGET_BOARD="LP_CC1352P7_1"

echo "=== TI DMM Firmware Build Script ==="
echo ""

# Function to find SDK
find_sdk() {
    for version in "${SDK_VERSIONS[@]}"; do
        local sdk_path="$HOME/ti/simplelink_cc13xx_cc26xx_sdk_${version}"
        if [ -d "$sdk_path" ]; then
            echo "$sdk_path"
            return 0
        fi
    done
    return 1
}

# Function to install SDK from downloaded .run file
install_sdk() {
    echo "🔍 Looking for SDK installer in $DOWNLOAD_DIR..."
    mkdir -p "$DOWNLOAD_DIR"

    local installer=$(find "$DOWNLOAD_DIR" -name "simplelink_cc13xx_cc26xx_sdk_*.run" -type f 2>/dev/null | head -1)

    if [ -z "$installer" ]; then
        echo "❌ No SDK installer found in $DOWNLOAD_DIR"
        echo ""
        echo "Please download the SDK installer:"
        echo "  See: $PROJECT_DIR/assets/MANUAL_SDK_DOWNLOAD.md"
        echo ""
        echo "Quick link: https://www.ti.com/tool/download/SIMPLELINK-CC13XX-CC26XX-SDK"
        echo "Save the .run file to: $DOWNLOAD_DIR/"
        return 1
    fi

    echo "✅ Found installer: $(basename "$installer")"
    echo ""
    echo "🚀 Installing SDK..."
    echo "  This will install to: $HOME/ti/"
    echo "  Installation takes ~5 minutes..."
    echo ""

    chmod +x "$installer"

    # Run installer in unattended mode
    if "$installer" --mode unattended --prefix "$HOME/ti"; then
        echo "✅ SDK installed successfully!"
        return 0
    else
        echo "❌ SDK installation failed"
        echo "  Try running manually: $installer"
        return 1
    fi
}

# Step 1: Check for SDK or install it
if [ "$1" == "--install" ]; then
    if ! install_sdk; then
        exit 1
    fi
fi

SDK_DIR=$(find_sdk)
if [ -z "$SDK_DIR" ]; then
    echo "❌ TI SimpleLink SDK not found"
    echo ""
    echo "Two options:"
    echo ""
    echo "1. Auto-install (recommended):"
    echo "   - Download SDK .run file from TI"
    echo "   - Save to: $DOWNLOAD_DIR/"
    echo "   - Run: $0 --install"
    echo ""
    echo "2. Manual install:"
    echo "   - See: $PROJECT_DIR/assets/MANUAL_SDK_DOWNLOAD.md"
    echo ""
    exit 1
fi

echo "✅ Found SDK at: $SDK_DIR"
SDK_VERSION=$(basename "$SDK_DIR" | sed 's/simplelink_cc13xx_cc26xx_sdk_//')

# Step 2: Check build tools
if ! command -v arm-none-eabi-gcc &> /dev/null; then
    echo "❌ ARM GCC compiler not found"
    echo ""
    echo "Install it:"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install gcc-arm-none-eabi binutils-arm-none-eabi"
    exit 1
fi

echo "✅ Found ARM GCC: $(arm-none-eabi-gcc --version | head -1)"

# Step 3: Navigate to DMM example
DMM_PATH="$SDK_DIR/examples/rtos/$TARGET_BOARD/dmm/$DMM_EXAMPLE"

if [ ! -d "$DMM_PATH" ]; then
    echo "❌ DMM example not found at: $DMM_PATH"
    exit 1
fi

echo "✅ Found DMM example: $DMM_PATH"
echo ""

# Step 4: Build firmware
echo "🔨 Building DMM firmware..."
echo "  This may take 5-10 minutes..."
echo ""

cd "$DMM_PATH"

# Set SDK path
export SIMPLELINK_CC13XX_CC26XX_SDK_INSTALL_DIR="$SDK_DIR"

# Clean previous build
if [ -d "tirtos7/gcc" ]; then
    echo "  Cleaning previous build..."
    make -C tirtos7/gcc clean
fi

# Build
echo "  Compiling..."
if make -C tirtos7/gcc all; then
    echo ""
    echo "✅ Build successful!"
else
    echo ""
    echo "❌ Build failed!"
    exit 1
fi

# Step 5: Copy output
OUTPUT_HEX=$(find . -name "*.hex" | head -1)

if [ -z "$OUTPUT_HEX" ]; then
    echo "❌ Could not find output .hex file"
    exit 1
fi

mkdir -p "$FIRMWARE_DIR"
cp "$OUTPUT_HEX" "$FIRMWARE_DIR/cc1352p7_dmm_zigbee_ble.hex"

echo ""
echo "✅ Firmware copied to: $FIRMWARE_DIR/cc1352p7_dmm_zigbee_ble.hex"
echo ""
echo "📊 Firmware info:"
ls -lh "$FIRMWARE_DIR/cc1352p7_dmm_zigbee_ble.hex"
echo ""
echo "Next steps:"
echo "  1. Flash firmware: ./scripts/flash_cc1352.sh assets/firmware/cc1352p7_dmm_zigbee_ble.hex"
echo "  2. Configure BLE: See assets/DMM_SETUP.md"
echo ""
