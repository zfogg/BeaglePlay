#!/bin/bash
# Flash CC1352P7 coordinator firmware on BeaglePlay
# This script manually controls GPIOs to enter bootloader mode

set -e

# Accept firmware path as argument, or use default
if [ -n "$1" ]; then
    FIRMWARE="$1"
else
    FIRMWARE="/opt/homeassistant/CC1352P7_coordinator_20250321.hex"
fi

BOOT_GPIO=552
RESET_GPIO=553
FLASHER="cc2538-bsl"
PORT="/dev/ttyS1"
BAUD=500000

echo "=== CC1352P7 Firmware Flasher ==="
echo "Firmware: $FIRMWARE"
echo "Port: $PORT"
echo ""

# Check if firmware file exists
if [ ! -f "$FIRMWARE" ]; then
    echo "Error: Firmware file not found: $FIRMWARE"
    exit 1
fi

# Export GPIOs if not already exported
export_gpio() {
    local gpio=$1
    if [ ! -d "/sys/class/gpio/gpio$gpio" ]; then
        echo "Exporting GPIO $gpio..."
        echo "$gpio" | sudo tee /sys/class/gpio/export > /dev/null
        sleep 0.1
    fi
}

# Set GPIO direction
set_direction() {
    local gpio=$1
    local dir=$2
    echo "$dir" | sudo tee /sys/class/gpio/gpio$gpio/direction > /dev/null
}

# Set GPIO value
set_value() {
    local gpio=$1
    local val=$2
    echo "$val" | sudo tee /sys/class/gpio/gpio$gpio/value > /dev/null
}

# Cleanup function
cleanup() {
    echo "Cleaning up GPIOs..."
    set_direction $BOOT_GPIO in || true
    set_direction $RESET_GPIO in || true
}
trap cleanup EXIT

# Export GPIOs
export_gpio $BOOT_GPIO
export_gpio $RESET_GPIO

# Enter bootloader mode
echo "Entering bootloader mode..."
set_direction $BOOT_GPIO out
set_direction $RESET_GPIO out

# Assert BOOT (low = enter bootloader)
set_value $BOOT_GPIO 0
sleep 0.1

# Reset the chip
set_value $RESET_GPIO 0
sleep 0.2
set_value $RESET_GPIO 1
sleep 0.3

echo "CC1352P7 should now be in bootloader mode"
echo ""

# Flash firmware
echo "Flashing firmware..."
sudo $FLASHER -p $PORT -b $BAUD -e -w -v "$FIRMWARE"

echo ""
echo "Flash complete! Resetting CC1352P7..."

# Reset to start application
set_value $BOOT_GPIO 1
sleep 0.1
set_value $RESET_GPIO 0
sleep 0.1
set_value $RESET_GPIO 1

echo "Done!"
