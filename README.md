# BeaglePlay

[@zfogg](https://github.com/zfogg)'s BeaglePlay setup - automated with Ansible.

## Quick Start

1. **Flash BeaglePlay** eMMC with the latest Debian flasher image from https://www.beagleboard.org/distros

2. **Configure SSH** on your local machine (`~/.ssh/config`):
   ```
   Host bp
       #HostName beagleplay
       HostName 192.168.7.2
       # NOTE: over usb it's 192.168.7.2, but you can change HostName to 
       # "beagleplay" after you connect to wifi and auth tailscale on the device
       User debian
       ForwardAgent yes
       RemoteForward 127.0.0.1:9999 /run/user/1000/gnupg/S.gpg-agent
   ```

3. **Deploy with Ansible**:
   ```bash
   make deploy
   ```

That's it. Your BeaglePlay is now configured with:
- Docker and home automation stack (diyHue, Zigbee2MQTT, Mosquitto, Home Assistant)
- GPG agent forwarding for remote git commit signing
- Optimized storage on SD card
- All necessary packages and tools

See [`ansible/README.md`](ansible/README.md) for detailed documentation.

## What Gets Installed

- **System packages**: zsh, git, neovim, tmux, fzf, ripgrep, and more
- **Docker**: Latest Docker CE with docker compose plugin
- **Home Automation**: Full stack with Philips Hue bridge emulation
- **GPG Forwarding**: Sign git commits using your local GPG key
- **Tailscale**: Secure network access (manual auth required)
- **Storage optimization**: Large directories mounted on SD card
- **terminfo**: For Kitty, so the shell works.


## Storage

We have the proper setup for the 256gb SDXC card I bought, which we previously 
used to flash Debian onto the eMMC. We wipe that and reconfigure it for device 
storage.

`/home`, `/opt`, docker data (`/var/lib/docker`), and `/var/log` are all stored on the sdcard and mounted on boot.


## Dotfiles

```bash
# Clone the dotfiles repo
git clone https://github.com/zfogg/dotfiles.git ~/src/github.com/zfogg/dotfiles

# Run the installer
cd ~/src/github.com/zfogg/dotfiles
./install.sh
```

The installer will:
- Create `~/.dotfiles` symlink pointing to the repo
- Symlink all dotfiles (`.zshrc`, `.tmux.conf`, etc.) through `~/.dotfiles`
- Symlink `.config/*` subdirectories individually
- Back up any existing files with timestamps
- Skip platform-specific files (e.g., `.inputrc.macos` on Linux)
