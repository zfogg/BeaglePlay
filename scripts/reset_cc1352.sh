#!/bin/bash
# Reset CC1352P7 for ZHA connection

BOOT_GPIO=552
RESET_GPIO=553

echo "Resetting CC1352P7..."

# Export GPIOs if needed
for gpio in $BOOT_GPIO $RESET_GPIO; do
    if [ ! -d "/sys/class/gpio/gpio$gpio" ]; then
        echo "$gpio" | sudo tee /sys/class/gpio/export > /dev/null
        sleep 0.1
    fi
done

# Set as outputs
echo "out" | sudo tee /sys/class/gpio/gpio$BOOT_GPIO/direction > /dev/null
echo "out" | sudo tee /sys/class/gpio/gpio$RESET_GPIO/direction > /dev/null

# Make sure BOOT is high (normal mode, not bootloader)
echo "1" | sudo tee /sys/class/gpio/gpio$BOOT_GPIO/value > /dev/null

# Reset the chip
echo "0" | sudo tee /sys/class/gpio/gpio$RESET_GPIO/value > /dev/null
sleep 0.2
echo "1" | sudo tee /sys/class/gpio/gpio$RESET_GPIO/value > /dev/null
sleep 0.5

# Release GPIOs
echo "in" | sudo tee /sys/class/gpio/gpio$BOOT_GPIO/direction > /dev/null
echo "in" | sudo tee /sys/class/gpio/gpio$RESET_GPIO/direction > /dev/null

echo "CC1352P7 reset complete. Ready for ZHA."
