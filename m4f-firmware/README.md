# BeaglePlay M4F Firmware

Bare-metal firmware for running code on the **ARM Cortex-M4F** core in BeaglePlay's AM62x SoC, with RemoteProc integration for communication with the Linux host.

## Overview

The BeaglePlay's AM62x SoC contains multiple processor cores:
- **Cortex-A53** (4 cores @ 1.4 GHz) - Main application processor running Linux
- **Cortex-M4F** (1 core @ 400 MHz) - Real-time MCU for low-latency tasks ← **This project**
- **Cortex-R5F** - Real-time processor for safety-critical applications
- **CC1352P7** - External radio co-processor (separate chip)

This firmware demonstrates:
- ✅ Running bare-metal C code on the M4F core
- ✅ RemoteProc framework integration
- ✅ Device tree overlay to enable M4F
- ✅ UART debugging output
- ✅ Resource table for memory management
- ⚠️ RPMsg stub (full IPC requires TI libraries or OpenAMP)

## Quick Start

### Prerequisites

**Development Machine:**
- LLVM/Clang toolchain with ARM target support
- Device tree compiler (`dtc`)
- SSH access to BeaglePlay

```bash
# Install dependencies (Debian/Ubuntu)
sudo apt install clang lld llvm device-tree-compiler

# Or via Homebrew (macOS/Linux)
brew install llvm dtc
```

### Build

```bash
cd m4f-firmware
make
```

This produces:
- `build/beagleplay-m4f.elf` - Firmware binary for RemoteProc
- `build/beagleplay-m4f.bin` - Raw binary
- `k3-am625-beagleplay-m4f.dtbo` - Device tree overlay

### Deploy with Ansible

```bash
cd ..
ansible-playbook playbook.yml --tags m4f_firmware
```

The Ansible role will:
1. Copy device tree overlay to `/boot/firmware/ti/`
2. Copy firmware to `/lib/firmware/am62-mcu-m4f0_0-fw`
3. Reboot if needed (first time only)

### Manual Control

After deployment and reboot:

```bash
# Start M4F
echo start | sudo tee /sys/class/remoteproc/remoteproc0/state

# Check status
cat /sys/class/remoteproc/remoteproc0/state  # Should show "running"

# Stop M4F
echo stop | sudo tee /sys/class/remoteproc/remoteproc0/state
```

## Project Structure

```
m4f-firmware/
├── src/
│   ├── main.c              - Main firmware with RPMsg stubs
│   ├── startup.c           - M4F startup code and vector table
│   ├── utils.c             - Bare-metal string/memory functions
│   └── resource_table.c    - RemoteProc resource table
├── include/
│   └── utils.h             - Utility function headers
├── build/                  - Build outputs (generated)
├── am62x-m4f.ld            - Linker script (memory layout)
├── k3-am625-beagleplay-m4f.dts   - Device tree overlay source
├── k3-am625-beagleplay-m4f.dtbo  - Compiled overlay
├── Makefile                - Build system
├── m4f-client.py           - Linux RPMsg client (for future use)
└── README.md               - This file
```

## Memory Layout

The M4F has dedicated on-chip memory:

| Region | Address      | Size  | Usage |
|--------|--------------|-------|-------|
| IRAM   | `0x05000000` | 192KB | Code, read-only data, resource table |
| DRAM   | `0x05040000` | 64KB  | Data, BSS, stack, heap |

These addresses are defined in:
- **Device tree**: `/proc/device-tree/bus@f0000/bus@4000000/m4fss@5000000/reg`
- **Linker script**: `am62x-m4f.ld`
- **Resource table**: `src/resource_table.c`

## Device Tree Overlay

The overlay (`k3-am625-beagleplay-m4f.dts`) adds:

1. **Reserved memory regions** for DMA and IPC:
   - `m4f-dma-memory`: 1MB @ `0x9cb00000`
   - `m4f-memory`: 2MB @ `0x9cc00000`

2. **Mailbox configuration** for inter-processor communication

3. **Enables M4F node** with memory-region and mbox properties

After applying this overlay, the M4F appears as `/sys/class/remoteproc/remoteproc0`.

## Firmware Features

The current firmware (`src/main.c`) implements:

- **Startup sequence**: Vector table, FPU enable, memory initialization
- **UART debug output**: Prints startup messages to MCU UART0
- **Heartbeat loop**: Periodic tick counter
- **RPMsg stubs**: Command protocol skeleton (ping, status, echo)

### Viewing Debug Output

The M4F outputs debug messages via UART (0x04A00000). To view:

```bash
# Find the serial port (may be ttyS0, ttyS3, etc.)
ls /dev/ttyS*

# Connect with screen
sudo screen /dev/ttyS0 115200
```

Expected output:
```
========================================
BeaglePlay M4F Firmware Starting
========================================
Core: ARM Cortex-M4F
Communication: RPMsg via shared memory
Ready to receive commands from Linux!
========================================
```

## Extending the Firmware

### Adding New Features

1. **Edit source code** in `src/main.c`
2. **Rebuild**: `make clean && make`
3. **Redeploy**: `ansible-playbook playbook.yml --tags m4f_firmware`
4. **Restart M4F**:
   ```bash
   echo stop | sudo tee /sys/class/remoteproc/remoteproc0/state
   echo start | sudo tee /sys/class/remoteproc/remoteproc0/state
   ```

### Implementing Full RPMsg

The current firmware has RPMsg **stubs**. For full bidirectional communication:

1. **Use TI IPC libraries** from Processor SDK, or
2. **Integrate OpenAMP** for standard RPMsg support
3. **Configure vrings** (already defined in reserved memory)
4. **Implement mailbox interrupts** (mailbox channels configured)

Resources:
- [TI IPC Documentation](https://software-dl.ti.com/processor-sdk-linux/esd/docs/latest/linux/Foundational_Components_IPC.html)
- [OpenAMP Project](https://github.com/OpenAMP/open-amp)
- [Linux RPMsg Documentation](https://www.kernel.org/doc/html/latest/staging/rpmsg.html)

### Accessing Hardware Peripherals

The M4F can access AM62x peripherals. Example for GPIO:

```c
#define MCU_GPIO_BASE 0x04201000

volatile uint32_t *gpio_set = (volatile uint32_t *)(MCU_GPIO_BASE + 0x38);
*gpio_set = (1 << 10);  // Set GPIO pin 10
```

**Important**: Consult the [AM62x Technical Reference Manual](https://www.ti.com/product/AM625) for peripheral addresses and ensure they're not claimed by Linux (check device tree).

## Troubleshooting

### M4F not appearing

```bash
# Check if overlay is loaded
ls /boot/firmware/ti/k3-am625-beagleplay-m4f.dtbo

# Check device tree
cat /proc/device-tree/bus@f0000/bus@4000000/m4fss@5000000/status
# Should show "okay" not "disabled"

# Check RemoteProc
ls /sys/class/remoteproc/
# remoteproc0 should be M4F (check: cat remoteproc0/name)
```

If M4F still doesn't appear after reboot, the overlay may not be loading. Verify it's in the correct location.

### Firmware won't start

```bash
# Check RemoteProc state
cat /sys/class/remoteproc/remoteproc0/state

# View error messages
dmesg | grep -i "m4\|remoteproc0"

# Common issues:
# - "Image is corrupted" → Use .elf file, not .bin
# - "bad phdr" → Memory addresses mismatch (check linker script)
# - "no reserved memory" → Device tree overlay not applied
```

### Build failures

```bash
# Verify LLVM toolchain
clang --version
ld.lld --version

# Check for ARM target support
llvm-config --targets-built | grep -i arm

# Clean and rebuild
make clean
make
```

## Performance & Use Cases

**M4F Characteristics:**
- Clock: ~400 MHz (configurable)
- Real-time: Deterministic, no OS overhead
- Latency: Microsecond-level response
- Memory: Limited (192KB code + 64KB data)

**Ideal For:**
- ✅ Fast GPIO toggling and bit-banging
- ✅ Motor control and PWM generation
- ✅ Sensor data acquisition and filtering
- ✅ Real-time control loops
- ✅ Low-latency interrupt handling

**Not Ideal For:**
- ❌ High-bandwidth data processing (use A53)
- ❌ Complex algorithms requiring lots of memory
- ❌ Network protocols (use Linux or CC1352)

## Development Workflow

```bash
# 1. Edit code
vim src/main.c

# 2. Build
make

# 3. Deploy
ansible-playbook ../playbook.yml --tags m4f_firmware

# 4. SSH to BeaglePlay and restart M4F
ssh bp
echo stop | sudo tee /sys/class/remoteproc/remoteproc0/state
echo start | sudo tee /sys/class/remoteproc/remoteproc0/state
dmesg | tail -20
```

## References

- [AM62x Technical Reference Manual](https://www.ti.com/product/AM625)
- [TI Processor SDK Linux](https://software-dl.ti.com/processor-sdk-linux/esd/docs/latest/)
- [Linux RemoteProc Framework](https://www.kernel.org/doc/html/latest/staging/remoteproc.html)
- [ARM Cortex-M4 TRM](https://developer.arm.com/documentation/100166/0001/)

## License

Example code for educational purposes.

## Contributing

Part of the BeaglePlay home automation project.
