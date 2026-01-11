# BeaglePlay

[@zfogg](https://github.com/zfogg)'s BeaglePlay setup - automated with Ansible.


## Quick Start

1. **Flash BeaglePlay** eMMC with the latest Debian flasher image from https://www.beagleboard.org/distros

2. **Configure SSH** on your local machine (`~/.ssh/config`):
   ```
   Host bp
       HostName 192.168.7.2  # USB connection initially
       User debian
       ForwardAgent yes
       RequestTTY yes
       RemoteForward 127.0.0.1:9999 /run/user/1000/gnupg/S.gpg-agent
   ```

3. **Connect to WiFi** (optional but recommended):
   ```bash
   ssh bp
   sudo nmcli device wifi connect "YOUR_SSID" password "YOUR_PASSWORD"
   ```

   You can keep using USB (192.168.7.2) or find your WiFi IP with `ip addr show wlan0`.

4. **Deploy with Ansible**:
   ```bash
   make deploy
   ```

That's it. Your BeaglePlay is now configured with:
- Docker and home automation stack (diyHue, Zigbee2MQTT, Mosquitto, Home Assistant)
- GPG agent forwarding for remote git commit signing
- Optimized storage on SD card
- All necessary packages and tools

**After Wi-Fi and Tailscale setup** (see post-installation message), update your SSH config to use the hostname:
```
Host bp
    HostName beagleplay  # Now using Tailscale hostname
    User debian
    ForwardAgent yes
    RequestTTY yes
    RemoteForward 127.0.0.1:9999 /run/user/1000/gnupg/S.gpg-agent
```

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

The operating system and its data is mostly installed and configured to the 
16gb eMMC, and we use the sdcard for substantial storage.

In this repo we have the proper setup for the 256gb sdxc card I bought, which 
we previously used to flash Debian onto the eMMC. Wipe that and reconfigure 
it for device storage.

`/home`, `/opt`, docker data (`/var/lib/docker`), and `/var/log` are all stored on the sdcard and mounted on boot.

Check `root/etc/fstab` to see details.


## Services & Ports

Once deployed, access these services at `beagleplay:port` (when connected via Tailscale) or `beagleplay.local:port` (on local network):

- **diyHue Bridge**: http://beagleplay:80 (or just http://beagleplay)
  - Philips Hue bridge emulator - connect Hue bulbs or link to Hue app

- **Zigbee2MQTT**: http://beagleplay:8080
  - Web interface for managing Zigbee devices
  - Pairs with CC1352 radio on BeaglePlay

- **Home Assistant**: http://beagleplay:8123
  - Home automation platform
  - Integrates with diyHue and Zigbee2MQTT

- **Mosquitto MQTT**: beagleplay:1883
  - MQTT broker (internal - used by Zigbee2MQTT and Home Assistant)


## @zfogg's .dotfiles

```bash
# Clone @zfogg's dotfiles repo
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


## Ready!

`ssh bp` and play around! Reset your password. You're a sudoer. `docker ps` to 
see the home automation stack and connect to it.

Connect some hue light bulbs to the bridge or the bridge to the app. Play with 
Home Assistant.
