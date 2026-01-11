#!/bin/bash
# Configure /dev/ttyS1 for ZHA use

PORT="/dev/ttyS1"

echo "Configuring $PORT for ZHA..."

# Reset the CC1352 first
/tmp/reset_cc1352.sh

# Configure serial port settings
sudo stty -F $PORT 115200 cs8 -cstopb -parenb -crtscts raw -echo
sudo chmod 666 $PORT

echo "Serial port configured:"
sudo stty -F $PORT -a | head -5

echo ""
echo "Now try adding ZHA in Home Assistant with these settings:"
echo "  - Device: $PORT"
echo "  - Radio: TI CC2531 or TI CC1352 (Z-Stack)"
echo "  - Baud: 115200  "
echo "  - Flow Control: Software (NOT Hardware!)"
