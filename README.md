# BeaglePlay Home Automation Stack

Complete home automation setup for BeaglePlay using its built-in CC1352 Zigbee radio. This stack provides a fully functional Philips Hue-compatible bridge using diyHue, Zigbee2MQTT, and Home Assistant.

**Author:** [@zfogg](https://github.com/zfogg/)

## Hardware

- **BeaglePlay** with CC1352P7 wireless co-processor
- **CC1352 Serial Device**: `/dev/ttyS1`
- **IEEE Address**: `00:12:4B:00:29:B9:57:27`
- **Firmware**: Z-Stack 3.x Coordinator (required for Zigbee operation)

## Architecture

```
Hue App (iOS/Android)
    ↓
diyHue Bridge (Hue API emulation)
    ↓
MQTT (Mosquitto)
    ↓
Zigbee2MQTT
    ↓
CC1352 Zigbee Radio (/dev/ttyS1)
    ↓
Zigbee Devices (bulbs, sensors, etc.)
```

## Services

All services run as Docker containers:

- **Mosquitto**: MQTT broker for device communication
- **Zigbee2MQTT**: Zigbee coordinator with web UI
- **diyHue**: Philips Hue bridge emulator
- **Home Assistant**: Optional automation platform

## Quick Start

### 1. Deploy to BeaglePlay

```bash
./scripts/deploy.sh
```

### 2. Start All Services

```bash
./scripts/start.sh
```

### 3. Access Services

- **Zigbee2MQTT UI**: http://beagleplay.local:8080
- **diyHue Bridge**: http://beagleplay.local
- **Home Assistant**: http://beagleplay.local:8123
- **MQTT Broker**: beagleplay.local:1883

## Setup Instructions

### Prerequisites

1. **SSH configured** with hostname `bp` in your `~/.ssh/config`:
   ```
   Host bp
       HostName beagleplay.local
       User debian
   ```

2. **CC1352 firmware flashed** (Z-Stack coordinator firmware)
   - See `assets/ZHA_SETUP.md` for firmware flashing instructions

### Initial Setup

1. **Clone this repository**:
   ```bash
   git clone https://github.com/zfogg/BeaglePlay.git
   cd BeaglePlay
   ```

2. **Deploy to BeaglePlay**:
   ```bash
   ./scripts/deploy.sh
   ```

3. **Start the stack**:
   ```bash
   ./scripts/start.sh
   ```

4. **Add Zigbee devices**:
   - Open Zigbee2MQTT UI: http://beagleplay.local:8080
   - Click "Permit join" to allow devices to pair
   - Put your Zigbee device in pairing mode
   - Wait for device to appear in Zigbee2MQTT

5. **Connect Hue app**:
   - Open the Philips Hue app
   - Scan for bridges
   - Add the diyHue bridge
   - Lights should appear automatically

## Scripts

### Management Scripts

- **`scripts/deploy.sh`**: Deploy configuration to BeaglePlay
- **`scripts/start.sh`**: Start all containers
- **`scripts/stop.sh`**: Stop all containers
- **`scripts/logs.sh <service>`**: View container logs

### CC1352 Management

- **`scripts/reset_cc1352.sh`**: Reset the CC1352 radio
- **`scripts/flash_cc1352.sh`**: Flash coordinator firmware
- **`scripts/setup_zha_serial.sh`**: Configure serial port for ZHA
- **`scripts/watch_for_bulb.sh`**: Monitor for new Zigbee devices

## Configuration

### Zigbee2MQTT

Configuration: `root/opt/beagleplay-stack/zigbee2mqtt/configuration.yaml`

Key settings:
- **Serial port**: `/dev/ttyS1`
- **Adapter**: `zstack` (TI Z-Stack)
- **Baud rate**: 115200
- **MQTT server**: `localhost:1883`

### diyHue

Configuration: `root/opt/beagleplay-stack/diyhue/`

- **config.yaml**: Bridge settings
- **lights.yaml**: Light definitions

**Important**: Auto-discovered lights default to white-only (LWB010). For color bulbs, manually edit `lights.yaml` and change `modelid: LCT015` to enable RGB color support.

### Mosquitto

Configuration: `root/opt/beagleplay-stack/mosquitto/mosquitto.conf`

Default settings allow anonymous access on port 1883 (suitable for local network only).

## Troubleshooting

### Lights Detected as White-Only

If color bulbs appear as dimmable-only in the Hue app:

1. Edit `root/opt/beagleplay-stack/diyhue/lights.yaml`
2. Change `modelid: LWB010` to `modelid: LCT015`
3. Add color state fields:
   ```yaml
   state:
     ct: 370
     hue: 8418
     sat: 140
     xy: [0.4573, 0.41]
     colormode: xy
     effect: none
   ```
4. Redeploy: `./scripts/deploy.sh`
5. Restart diyHue: `ssh bp "cd /home/debian/beagleplay-stack && docker-compose restart diyhue"`
6. Force-close and reopen the Hue app

### CC1352 Not Responding

```bash
ssh bp
./scripts/reset_cc1352.sh
docker restart zigbee2mqtt
```

### View Logs

```bash
./scripts/logs.sh zigbee2mqtt  # or mosquitto, diyhue, homeassistant
```

## Directory Structure

```
BeaglePlay/
├── docker-compose.yml          # Main orchestration file
├── root/                        # Files deployed to / on device
│   └── opt/
│       └── beagleplay-stack/   # Configuration files
│           ├── diyhue/         # diyHue bridge config
│           ├── zigbee2mqtt/    # Zigbee coordinator config
│           ├── mosquitto/      # MQTT broker config
│           └── homeassistant/  # Home Assistant config
├── scripts/                     # Management scripts
│   ├── deploy.sh               # Deploy to BeaglePlay
│   ├── start.sh                # Start containers
│   ├── stop.sh                 # Stop containers
│   ├── logs.sh                 # View logs
│   ├── pull-configs.sh         # Pull configs from device
│   ├── reset_cc1352.sh         # Reset Zigbee radio
│   ├── flash_cc1352.sh         # Flash firmware
│   ├── watch_for_bulb.sh       # Monitor pairing
│   ├── build_dmm_firmware.sh   # Build DMM firmware (Zigbee+BLE)
│   └── setup_dmm.sh            # DMM setup helper
├── assets/                      # Documentation and assets
│   ├── ZHA_SETUP.md            # Detailed Zigbee setup
│   ├── DMM_SETUP.md            # DMM architecture & config
│   ├── DMM_QUICKSTART.md       # DMM 3-step guide
│   ├── BUILD_DMM_FIRMWARE.md   # Complete build guide
│   ├── MANUAL_SDK_DOWNLOAD.md  # SDK download instructions
│   ├── firmware/               # Firmware binaries
│   └── reset_hue_power_cycle.md
├── DMM_STATUS.md                # Current DMM setup status
└── README.md                    # This file
```

## Advanced: DMM (Zigbee + BLE Simultaneously)

The CC1352P7 supports **Dynamic Multi-protocol Manager (DMM)**, enabling simultaneous Zigbee Coordinator + BLE5 operation for presence detection and phone tracking.

### Status: Ready for SDK Download

Everything is prepared for automated DMM firmware build. Only one manual step required:

1. **Download TI SDK** (requires free TI account):
   - Visit: https://www.ti.com/tool/download/SIMPLELINK-CC13XX-CC26XX-SDK/8.30.01.01
   - Save installer to: `~/Downloads/ti-sdk/`

2. **Run automated build**:
   ```bash
   ./scripts/build_dmm_firmware.sh --install
   ```

3. **Flash and test** (automated)

### Quick Reference

- **Quick Start**: See `DMM_STATUS.md` - Current status and next steps
- **3-Step Guide**: See `assets/DMM_QUICKSTART.md` - Fast setup
- **Download Help**: See `assets/MANUAL_SDK_DOWNLOAD.md` - SDK download instructions
- **Build Details**: See `assets/BUILD_DMM_FIRMWARE.md` - Complete build reference
- **Architecture**: See `assets/DMM_SETUP.md` - DMM configuration and theory

### What DMM Gives You

- ✅ **Keep Zigbee**: All existing devices work, backward compatible
- ✅ **Add BLE**: Presence detection, beacons, phone tracking
- ✅ **Room Tracking**: Know which room phones are in
- ✅ **Direct Bluetooth**: No additional hardware needed

### Current Setup

```
Firmware: Z-Stack 3.x Coordinator (Zigbee-only)
Status: Fully functional, stable
```

### After DMM

```
Firmware: DMM (Zigbee Coordinator + BLE5)
Status: Both protocols working simultaneously
Trade-off: ~10-50ms latency increase, both protocols functional
```

## Resources

- [BeagleBoard.org](https://www.beagleboard.org/boards/beagleplay)
- [BeaglePlay Forum](https://forum.beagleboard.org/tag/play)
- [Zigbee2MQTT Documentation](https://www.zigbee2mqtt.io/)
- [diyHue Documentation](https://diyhue.org/)
- [Home Assistant](https://www.home-assistant.io/)
- [TI DMM Examples](https://github.com/TexasInstruments/simplelink-dmm-examples)
- [TI SimpleLink SDK](https://www.ti.com/tool/SIMPLELINK-CC13XX-CC26XX-SDK)

## License

MIT
