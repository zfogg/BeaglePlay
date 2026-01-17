# M4F Firmware Ansible Role

Deploys and manages M4F firmware on BeaglePlay's Cortex-M4F core.

## Description

This role:
- Installs the M4F device tree overlay to enable the M4F core
- Deploys the compiled M4F firmware to `/lib/firmware/`
- Optionally starts the M4F firmware automatically
- Provides idempotent deployment

## Requirements

- BeaglePlay with AM62x SoC
- Device tree overlay compiled (`m4f-firmware/k3-am625-beagleplay-m4f.dtbo`)
- M4F firmware built (`m4f-firmware/build/beagleplay-m4f.elf`)

## Role Variables

```yaml
# Whether to install the M4F firmware binary
m4f_firmware_install: true

# Whether to automatically start the M4F after deployment
m4f_firmware_autostart: false
```

## Dependencies

None

## Example Playbook

```yaml
---
- hosts: beagleplay
  roles:
    - m4f_firmware
```

Or with custom variables:

```yaml
---
- hosts: beagleplay
  roles:
    - role: m4f_firmware
      vars:
        m4f_firmware_autostart: true
```

## Post-Deployment

After the first deployment with the device tree overlay, a **reboot is required** to enable the M4F core.

### Manual M4F Control

```bash
# Start M4F
echo start | sudo tee /sys/class/remoteproc/remoteproc0/state

# Stop M4F
echo stop | sudo tee /sys/class/remoteproc/remoteproc0/state

# Check status
cat /sys/class/remoteproc/remoteproc0/state
```

## Files Deployed

| Source | Destination | Purpose |
|--------|-------------|---------|
| `root/boot/firmware/ti/k3-am625-beagleplay-m4f.dtbo` | `/boot/firmware/ti/` | Device tree overlay |
| `m4f-firmware/build/beagleplay-m4f.elf` | `/lib/firmware/am62-mcu-m4f0_0-fw` | M4F firmware binary |

## License

Same as parent project

## Author

BeaglePlay M4F Firmware Project
