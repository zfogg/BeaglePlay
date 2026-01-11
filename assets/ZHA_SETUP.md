# BeaglePlay ZHA Setup Guide

## Current Configuration

### Hardware
- **BeaglePlay** with CC1352P7 wireless co-processor
- **CC1352 Serial Device**: `/dev/ttyS1` (NOT /dev/ttyS4)
- **IEEE Address**: `00:12:4B:00:29:B9:57:27`

### Boot Configuration
- **Boot mode**: `eMMC disable BCFSERIAL`
- **Overlay**: `k3-am625-beagleplay-bcfserial-no-firmware.dtbo`
- **Effect**: Disables Greybus driver, exposes CC1352 as raw UART

### Firmware
- **Firmware**: Z-Stack 3.x Coordinator (March 2025)
- **File**: `CC1352P7_coordinator_20250321.hex`
- **Status**: Successfully flashed and verified

## ZHA Configuration (Attempt)

### Settings That Should Work
1. **Radio Type**: `ZNP (Texas Instruments Z-Stack)`
2. **Serial Device**: `/dev/ttyS1`
3. **Baud Rate**: `115200`
4. **Flow Control**: `software` (NOT hardware)

### Current Issue
- ZHA hangs indefinitely when trying to connect
- No error messages in logs
- CC1352 confirmed responding to Z-Stack commands manually

## Scripts Created

### Reset CC1352
```bash
/tmp/reset_cc1352.sh
```
Resets the CC1352 using GPIO control.

### Flash CC1352 Firmware
```bash
/home/zfogg/src/github.com/zfogg/BeaglePlay/flash_cc1352.sh
```
Flashes coordinator firmware with GPIO bootloader control.

### Setup Serial Port for ZHA
```bash
/tmp/setup_zha_serial.sh
```
Configures /dev/ttyS1 with correct serial settings.

## Verified Working
```python
# Test Z-Stack communication
import serial, time
ser = serial.Serial('/dev/ttyS1', 115200, timeout=1)
ser.write(b'\xfe\x00\x21\x01\x20')  # SYS_PING
time.sleep(0.5)
print(ser.read(ser.in_waiting).hex())  # Should return: fe02610159063d
ser.close()
```

## Next Steps to Try

1. **Try different ZHA radio types in this order**:
   - `deconz`
   - `znp`
   - `zigate`

2. **Enable ZHA debug logging** in Home Assistant:
   Add to `configuration.yaml`:
   ```yaml
   logger:
     default: info
     logs:
       homeassistant.components.zha: debug
       zigpy: debug
       bellows: debug
       zigpy_znp: debug
   ```

3. **Alternative: Use zigbee2mqtt** (more reliable debugging):
   - Requires MQTT broker (mosquitto)
   - Better debug output
   - Known to work well with CC1352

## Important Notes

- Docker Compose maps both `/dev/ttyS1` and `/dev/ttyS4`
- Some guides reference ttyS4, but on current images CC1352 is ttyS1
- CC1352 GPIOs: GPIO 552 (boot), GPIO 553 (reset)
- The guide at hackster.io may use older image where ttyS4 was correct
