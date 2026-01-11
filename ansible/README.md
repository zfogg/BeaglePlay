# BeaglePlay Ansible Configuration

This directory contains Ansible playbooks and roles to configure your BeaglePlay device.

## Prerequisites

1. **Ansible installed** on your local machine:
   ```bash
   pip install ansible
   ```

2. **SSH access** to BeaglePlay configured in `~/.ssh/config`:
   ```
   Host bp
       HostName beagleplay
       User debian
       ForwardAgent yes
       RemoteForward 127.0.0.1:9999 /run/user/1000/gnupg/S.gpg-agent
   ```

3. **SD card formatted** and UUID updated in `inventory.yml`

## Quick Start

Deploy everything to BeaglePlay:
```bash
ansible-playbook playbook.yml
```

## Selective Deployment

Deploy only specific components using tags:

```bash
# Install packages and basic setup only
ansible-playbook playbook.yml --tags common

# Configure storage/fstab only
ansible-playbook playbook.yml --tags storage

# Install Docker only
ansible-playbook playbook.yml --tags docker

# Deploy home automation stack only
ansible-playbook playbook.yml --tags home_automation

# Setup GPG forwarding only
ansible-playbook playbook.yml --tags gpg
```

## Roles

### common
- Installs system packages (zsh, git, neovim, etc.)
- Installs uv (Python package manager)
- Configures sudoers
- Installs Kitty terminfo

### storage
- Configures `/etc/fstab` for SD card storage
- Sets up bind mounts for `/home`, `/opt`, `/var/lib/docker`, `/var/log`

### docker
- Removes old Docker packages
- Installs Docker CE from official repository
- Adds debian user to docker group
- Enables Docker service

### home_automation
- Deploys docker-compose.yml
- Configures diyHue, Zigbee2MQTT, Mosquitto, Home Assistant
- Starts the home automation stack

### gpg_forwarding
- Deploys GPG agent forwarding systemd service
- Configures GPG for remote signing
- Enables and starts the forwarding service

## Configuration

Edit `ansible/inventory.yml` to customize:
- Storage device UUID
- Zigbee configuration
- Feature toggles (enable/disable components)

## Post-Deployment

After running the playbook:

1. Configure Tailscale:
   ```bash
   ssh bp 'sudo tailscale up'
   ssh bp 'sudo tailscale set --operator=debian'
   ssh bp 'tailscale set --ssh=true'
   ```

2. Access services:
   - Zigbee2MQTT UI: http://beagleplay.local:8080
   - diyHue Bridge: http://beagleplay.local
   - Home Assistant: http://beagleplay.local:8123

## Troubleshooting

View playbook with verbose output:
```bash
ansible-playbook playbook.yml -v
```

Check syntax:
```bash
ansible-playbook playbook.yml --syntax-check
```

Dry run (check mode):
```bash
ansible-playbook playbook.yml --check
```
