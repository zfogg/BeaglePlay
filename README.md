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


## WiFi Setup

After initial deployment over USB, connect BeaglePlay to WiFi:

1. **Connect to your network** (replace `SSID` and `password`):
   ```bash
   ssh bp
   sudo nmcli device wifi connect "SSID" password "password"
   ```

2. **Find the WiFi IP address**:
   ```bash
   ip addr show wlan0 | grep "inet "
   ```

3. **Update your SSH config** (`~/.ssh/config`) to use the hostname instead of USB IP:
   ```
   Host bp
       HostName beagleplay    # Changed from 192.168.7.2
       User debian
       ForwardAgent yes
       RemoteForward 127.0.0.1:9999 /run/user/1000/gnupg/S.gpg-agent
   ```

4. **Connect via WiFi**:
   ```bash
   ssh bp
   ```

Once Tailscale is configured (see post-installation message), you can use `HostName beagleplay` to connect from anywhere on your tailnet.


## What Gets Installed

- **System packages**: zsh, git, neovim, tmux, fzf, ripgrep, and more
- **Docker**: Latest Docker CE with docker compose plugin
- **Home Automation**: Full stack with Philips Hue bridge emulation
- **GPG Forwarding**: Sign git commits using your local GPG key
- **Tailscale**: Secure network access (manual auth required)
- **Storage optimization**: Large directories mounted on SD card
- **terminfo**: For Kitty, so the shell works.


## Storage

The operating system and its data is mostly installed and configured to the 
16gb eMMC, and we use the sdcard for substantial storage.

In this repo we have the proper setup for the 256gb sdxc card I bought, which 
we previously used to flash Debian onto the eMMC. Wipe that and reconfigure 
it for device storage.

`/home`, `/opt`, docker data (`/var/lib/docker`), and `/var/log` are all stored on the sdcard and mounted on boot.

Check `root/etc/fstab` to see details.


## .dotfiles

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


## Ready!

`ssh bp` and play around! Reset your password. You're a sudoer. `docker ps` to 
see the home automation stack and connect to it.
