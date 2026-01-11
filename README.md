# BeaglePlay

[@zfogg](https://github.com/zfogg)'s BeaglePlay setup - automated with Ansible.

## Quick Start

1. **Flash BeaglePlay** with the latest Debian image from https://www.beagleboard.org/distros

2. **Configure SSH** on your local machine (`~/.ssh/config`):
   ```
   Host bp
       HostName beagleplay
       User debian
       ForwardAgent yes
       RemoteForward 127.0.0.1:9999 /run/user/1000/gnupg/S.gpg-agent
   ```

3. **Deploy with Ansible**:
   ```bash
   make deploy
   ```

That's it! Your BeaglePlay is now configured with:
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


## Storage

We have `root/etc/fstab` with the proper setup for the 256gb SDXC card I 
bought, which we previously used to flash Debian onto the eMMC. We wipe that 
and reconfigure it for device storage.

`/home`, `/opt`, docker data (`/var/lib/docker`), and `/var/log` are all stored on the sdcard and mounted on boot.


## Extras

Be sure to enable the systemctl service `gpg-agent-forward.service` and see the 
example for how to configure your ssh config file. For the "debian" user if 
this is per-user.

Use `tic` to install Kitty's terminfo from `assets/`. Is this per-user too? For 
the "debian" user as well then.

Manually install neovim nightly (or latest v0.12 release) to /opt/nvim-nightly 
and symlink it to where it needs to go (TODO: this needs to be automated by 
ansible).

dotfiles:
1. Clone Zachary's dotfiles repo from github: `git clone 
   https://github.com/zfogg/dofiles.git ~/src/github.com/zfogg/dotfiles`
2. Symlink `~/.dotfiles` to it and run `~/.dotfiles/install.sh` (TODO: we 
   need this install file. It should symlink everything like it's symlinked 
   now. some things are symlinked at the root and some are not. most are tho. 
   not the .git and install scripts and macos stuff).
