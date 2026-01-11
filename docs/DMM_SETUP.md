# CC1352P7 DMM Setup - Zigbee + BLE Simultaneously

## Overview

The CC1352P7 on BeaglePlay can run **both Zigbee Coordinator AND BLE** at the same time using TI's Dynamic Multi-protocol Manager (DMM).

**Current Status**: BeaglePlay is running Z-Stack 3.x Coordinator (Zigbee only)
**Target**: DMM firmware with Zigbee Coordinator + BLE5 Peripheral

## DMM Architecture

```
┌─────────────────────────────────────┐
│         Application Layer           │
│  ┌──────────────┬─────────────────┐ │
│  │ Zigbee Stack │   BLE5 Stack    │ │
│  └──────────────┴─────────────────┘ │
├─────────────────────────────────────┤
│   Dynamic Multi-protocol Manager    │
│         (DMM Driver)                │
├─────────────────────────────────────┤
│      TI-RTOS / Radio Scheduler      │
├─────────────────────────────────────┤
│         CC1352P7 Hardware           │
└─────────────────────────────────────┘
```

DMM uses time-slicing to share the radio between protocols:
- **Zigbee**: Coordinator functionality (mesh network)
- **BLE**: Peripheral role (advertising, connections)

## What You'll Get

### Zigbee Coordinator
- ✅ Keep existing Zigbee devices (lights, sensors)
- ✅ Works with Zigbee2MQTT
- ✅ Mesh networking
- ✅ Low power device support

### BLE5 Peripheral
- ✅ Phone presence detection
- ✅ BLE beacons
- ✅ Direct phone communication
- ✅ Room-level tracking

## Requirements

### Hardware
- ✅ BeaglePlay with CC1352P7 (you have this!)
- ✅ UART access to `/dev/ttyS1` (configured)
- ✅ GPIO control (reset/bootloader)

### Software Tools
1. **TI SimpleLink CC13xx/CC26xx SDK** v7.x+
2. **Code Composer Studio** (CCS) OR **command-line tools**
3. **uniflash** OR **cc2538-bsl** for flashing
4. **BLE stack** configuration tools

### Current BeaglePlay Configuration
```
CC1352 Device: /dev/ttyS1
Baud Rate: 115200
Boot Mode: BCFSERIAL (raw UART, no Greybus)
Current Firmware: Z-Stack 3.x Coordinator
IEEE Address: 00:12:4B:00:29:B9:57:27
```

## Setup Options

### Option 1: Pre-built DMM Firmware (Easiest)
Look for pre-built binaries from:
- TI Resource Explorer
- Community builds (GitHub, TI forums)
- BeagleBoard community firmware

**Status**: Need to search for existing builds

### Option 2: Build from TI SDK (Full Control)
Build the official DMM example:
```
SimpleLink SDK Path:
[SDK]/examples/rtos/LP_CC1352P7_1/dmm/dmm_zc_switch_remote_display_app/
```

**Files needed**:
- `dmm_zc_switch_remote_display_app.c` - Main application
- `dmm_policy.c` - Protocol scheduling policy
- Linker config, RTOS config, BLE profiles

## Implementation Plan

### Phase 1: Backup Current Setup ✓
```bash
# Already done - configs backed up in /tmp/config-backup/
# Zigbee device database saved in /opt/beagleplay-stack/zigbee2mqtt/
```

### Phase 2: Obtain DMM Firmware

#### Option A: Search for Pre-built
1. Check TI Resource Explorer
2. Search GitHub for CC1352P7 DMM builds
3. Check BeagleBoard forums

#### Option B: Build from Source
1. Install TI SimpleLink SDK
2. Install CCS or command-line tools
3. Build dmm_zc_switch_remote_display project
4. Generate .hex file

### Phase 3: Flash DMM Firmware

Using existing flash script (modified):
```bash
# scripts/flash_cc1352_dmm.sh
#!/bin/bash
# Flash DMM firmware to CC1352P7

FIRMWARE="/path/to/dmm_firmware.hex"
DEVICE="/dev/ttyS1"

# Reset CC1352 to bootloader
./scripts/reset_cc1352.sh bootloader

# Flash firmware
python3 cc2538-prog.py \
    -p $DEVICE \
    -e -w -v \
    $FIRMWARE

# Reset to run mode
./scripts/reset_cc1352.sh
```

### Phase 4: Software Stack Configuration

#### Zigbee Side (Zigbee2MQTT)
- Should work mostly unchanged
- DMM firmware exposes Z-Stack interface on UART
- May need minor config tweaks for timing

#### BLE Side (New)
Need to add BLE management:

**Option 1**: Use `bluez` + `bluetoothctl`
```bash
# Monitor BLE advertisements
hcitool lescan

# Connect to BLE peripheral
bluetoothctl connect <address>
```

**Option 2**: Custom Python/Node.js BLE client
- Read DMM BLE characteristics
- Handle presence detection
- Integrate with Home Assistant (optional)

**Option 3**: Room Assistant
- Open source BLE presence detection
- Works with Home Assistant
- Tracks phones/beacons by room

### Phase 5: DMM Configuration

DMM Policy settings control radio scheduling:

```c
// Example DMM policy (in firmware)
DMM_POLICY_ZIGBEE_PRIORITY_HIGH    // Zigbee messages prioritized
DMM_POLICY_BLE_CONNECTION_WINDOW   // BLE connection events guaranteed
DMM_POLICY_BALANCED               // Equal sharing
```

**Key parameters**:
- Zigbee poll rate
- BLE advertising interval
- Connection interval priority
- Scan window timing

## Testing Plan

### Test 1: Zigbee Functionality
```bash
# Check Zigbee coordinator is up
docker logs zigbee2mqtt | grep "started"

# Test existing bulb communication
mosquitto_pub -t "zigbee2mqtt/0x001788010ebc5503/set" -m '{"state":"ON"}'
```

### Test 2: BLE Functionality
```bash
# Scan for BLE devices
sudo hcitool lescan

# Check DMM BLE advertisement
sudo bluetoothctl
> scan on
```

### Test 3: Concurrent Operation
1. Control Zigbee light while BLE scanning
2. Monitor for packet loss or delays
3. Check DMM statistics (if available)

## Performance Considerations

### Radio Time Sharing
- **Zigbee**: ~40-60% radio time (mesh routing + data)
- **BLE**: ~40-60% radio time (advertising + connections)
- **Overhead**: ~10% (DMM scheduler)

### Latency Impact
- Zigbee commands: +10-50ms delay (vs Zigbee-only)
- BLE connections: May have gaps during Zigbee activity
- Both protocols remain functional

### Range Considerations
Both protocols share the same 2.4 GHz radio:
- Zigbee: ~50m indoor range (unchanged)
- BLE: ~10-30m range (typical)

## Rollback Plan

If DMM doesn't work or causes issues:

```bash
# Reflash original Z-Stack firmware
./scripts/flash_cc1352.sh /path/to/original_zstack.hex

# Restart Zigbee2MQTT
docker-compose restart zigbee2mqtt
```

**Backup locations**:
- Original firmware: `assets/firmware/CC1352P7_coordinator_20250321.hex`
- Zigbee database: `/opt/beagleplay-stack/zigbee2mqtt/database.db`
- Device configs: `/tmp/config-backup/`

## Next Steps

1. **Decide on approach**:
   - [ ] Search for pre-built DMM firmware first
   - [ ] Set up build environment if needed

2. **Document findings**:
   - [ ] Available firmware versions
   - [ ] Build requirements
   - [ ] Known compatibility issues

3. **Test in stages**:
   - [ ] Flash DMM firmware
   - [ ] Verify Zigbee still works
   - [ ] Enable and test BLE
   - [ ] Optimize DMM scheduling

## Resources

- [TI DMM Documentation](https://dev.ti.com/tirex/explore/node?node=A__AD.r0R2G-VazpVd8UtXCQ__com.ti.SIMPLELINK_CC13XX_CC26XX_SDK__BSEc4rl__LATEST)
- [CC1352P7 Technical Reference](https://www.ti.com/product/CC1352P7)
- [SimpleLink SDK](https://www.ti.com/tool/SIMPLELINK-CC13XX-CC26XX-SDK)
- [Zigbee2MQTT Hardware](https://www.zigbee2mqtt.io/guide/adapters/)
- [DMM Examples GitHub](https://github.com/TexasInstruments/simplelink-dmm-examples)

## Status Tracking

- [x] Research DMM capabilities
- [x] Document current setup
- [ ] Obtain DMM firmware
- [ ] Flash and test DMM
- [ ] Configure BLE stack
- [ ] Optimize performance
- [ ] Document final configuration
