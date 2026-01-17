# Makefile for BeaglePlay M4F Firmware
# Builds firmware for AM62x Cortex-M4F core

# Toolchain configuration - using LLVM/Clang
CC = clang
LD = ld.lld
OBJCOPY = llvm-objcopy
OBJDUMP = llvm-objdump
SIZE = llvm-size

# Project name
PROJECT = beagleplay-m4f

# Directories
SRC_DIR = src
INC_DIR = include
BUILD_DIR = build

# Source files
C_SOURCES = $(wildcard $(SRC_DIR)/*.c)
OBJECTS = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(C_SOURCES))

# Linker script
LDSCRIPT = am62x-m4f.ld

# Compiler flags for Clang
CFLAGS = --target=arm-none-eabi \
         -mcpu=cortex-m4 \
         -mthumb \
         -mfloat-abi=hard \
         -mfpu=fpv4-sp-d16 \
         -O2 \
         -g \
         -Wall \
         -Wextra \
         -I$(INC_DIR) \
         -ffunction-sections \
         -fdata-sections \
         -nostdlib \
         -nostartfiles \
         -ffreestanding

# Linker flags for lld
LDFLAGS = -T$(LDSCRIPT) \
          --gc-sections \
          -Map=$(BUILD_DIR)/$(PROJECT).map \
          -nostdlib

# Output files
ELF = $(BUILD_DIR)/$(PROJECT).elf
BIN = $(BUILD_DIR)/$(PROJECT).bin
HEX = $(BUILD_DIR)/$(PROJECT).hex
LST = $(BUILD_DIR)/$(PROJECT).lst

# Default target
all: $(BUILD_DIR) $(ELF) $(BIN) $(HEX) $(LST) size

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Compile C files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "CC $<"
	@$(CC) $(CFLAGS) -c $< -o $@

# Link
$(ELF): $(OBJECTS)
	@echo "LD $@"
	@$(LD) $(LDFLAGS) $(OBJECTS) -o $@

# Create binary
$(BIN): $(ELF)
	@echo "OBJCOPY $@"
	@$(OBJCOPY) -O binary $< $@

# Create hex file
$(HEX): $(ELF)
	@echo "OBJCOPY $@"
	@$(OBJCOPY) -O ihex $< $@

# Create disassembly listing
$(LST): $(ELF)
	@echo "OBJDUMP $@"
	@$(OBJDUMP) --disassemble --source $< > $@

# Show size information
size: $(ELF)
	@echo ""
	@echo "=== Size Information ==="
	@$(SIZE) $<
	@echo ""

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)

# Deploy via Ansible (recommended)
deploy: all
	@echo "Deploying M4F firmware via Ansible..."
	@cd .. && ansible-playbook playbook.yml --tags m4f_firmware
	@echo ""
	@echo "✓ M4F firmware deployed"
	@echo ""
	@echo "Control M4F on BeaglePlay:"
	@echo "  echo start | sudo tee /sys/class/remoteproc/remoteproc0/state"
	@echo "  echo stop  | sudo tee /sys/class/remoteproc/remoteproc0/state"

# Legacy: Manual install (use 'make deploy' instead)
install: $(ELF)
	@echo "Copying firmware to BeaglePlay (manual mode)..."
	@scp -o "RequestTTY=no" $(ELF) bp:~/am62-mcu-m4f0_0-fw
	@echo "✓ Firmware copied to ~/am62-mcu-m4f0_0-fw"
	@echo ""
	@echo "Next steps on BeaglePlay:"
	@echo "  sudo mv ~/am62-mcu-m4f0_0-fw /lib/firmware/"
	@echo "  echo start | sudo tee /sys/class/remoteproc/remoteproc0/state"

# Start M4F firmware remotely
start:
	@echo "Starting M4F firmware..."
	@ssh -o "RequestTTY=no" bp 'echo start | sudo tee /sys/class/remoteproc/remoteproc0/state'

# Stop M4F firmware remotely
stop:
	@echo "Stopping M4F firmware..."
	@ssh -o "RequestTTY=no" bp 'echo stop | sudo tee /sys/class/remoteproc/remoteproc0/state'

# Install M4F device tree overlay (handled by Ansible)
install-overlay: k3-am625-beagleplay-m4f.dtbo
	@echo "Device tree overlay compiled."
	@echo "Use 'ansible-playbook playbook.yml' to deploy to BeaglePlay"

# Compile device tree overlay
%.dtbo: %.dts
	@echo "Compiling device tree overlay..."
	@dtc -@ -I dts -O dtb -o $@ $<

# Show M4F status
status:
	@echo "=== M4F RemoteProc Status ==="
	@ssh -o "RequestTTY=no" bp 'cat /sys/class/remoteproc/remoteproc0/name 2>/dev/null || echo "M4F not available"'
	@ssh -o "RequestTTY=no" bp 'cat /sys/class/remoteproc/remoteproc0/state 2>/dev/null || echo "M4F not enabled"'
	@ssh -o "RequestTTY=no" bp 'cat /sys/class/remoteproc/remoteproc0/firmware 2>/dev/null || true'

# Help
help:
	@echo "BeaglePlay M4F Firmware Build System"
	@echo ""
	@echo "Targets:"
	@echo "  all            - Build firmware (default)"
	@echo "  clean          - Remove build artifacts"
	@echo "  deploy         - Build and deploy via Ansible (recommended)"
	@echo "  install        - Manual firmware copy (legacy)"
	@echo "  start          - Start M4F firmware remotely"
	@echo "  stop           - Stop M4F firmware remotely"
	@echo "  status         - Show M4F status remotely"
	@echo "  size           - Show firmware size"
	@echo ""
	@echo "Quick Start:"
	@echo "  1. make               # Build firmware"
	@echo "  2. make deploy        # Deploy to BeaglePlay via Ansible"
	@echo "  3. make start         # Start M4F firmware"
	@echo "  4. make status        # Check M4F status"
	@echo ""
	@echo "Build Requirements:"
	@echo "  - LLVM/Clang toolchain (clang, lld, llvm-objcopy, llvm-objdump)"
	@echo "  - device-tree-compiler (dtc)"
	@echo "  - SSH access to BeaglePlay"
	@echo "  - Ansible (for deployment)"
	@echo ""

.PHONY: all clean deploy install install-overlay start stop status size help
