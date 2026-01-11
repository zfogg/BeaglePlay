# GPG Key Forwarding Setup

This setup enables GPG signing on the BeaglePlay using your local GPG key forwarded over SSH. This allows you to sign git commits on the remote device without storing your private key there.

## Architecture

```
Local Machine                    BeaglePlay
┌─────────────┐                 ┌──────────────────────┐
│             │                 │                      │
│ GPG Agent   │                 │  systemd service     │
│ (socket)    │                 │  (socat bridge)      │
│             │                 │                      │
│ /run/user/  │    SSH          │  TCP :9999           │
│  1000/      │ ─────────────>  │      ↓               │
│  gnupg/     │  RemoteForward  │  Unix socket         │
│  S.gpg-     │                 │  /run/user/1000/     │
│  agent      │                 │   gnupg/S.gpg-agent  │
│             │                 │      ↓               │
│             │                 │  GPG operations      │
│             │                 │  (git commit -S)     │
└─────────────┘                 └──────────────────────┘
```

## How It Works

1. **SSH Port Forwarding**: SSH forwards the local GPG socket to TCP port 9999 on BeaglePlay
2. **socat Bridge**: A systemd service bridges TCP port 9999 to a Unix socket
3. **GPG Configuration**: Remote GPG uses loopback pinentry mode to work with the forwarded agent
4. **Automatic Startup**: The systemd service starts automatically and restarts on failure

## Required Files

### On Local Machine

**`~/.ssh/config`** - SSH configuration for GPG forwarding:
```ssh
Host bp
  HostName beagleplay
  User debian
  ForwardAgent yes
  RequestTTY yes
  RemoteForward 127.0.0.1:9999 /run/user/1000/gnupg/S.gpg-agent
```

**`~/.gnupg/gpg-agent.conf`** - Enable loopback pinentry:
```conf
allow-loopback-pinentry
```

### On BeaglePlay

The following files are included in this repository under `root/home/debian/`:

**`.config/systemd/user/gpg-agent-forward.service`** - systemd service:
```ini
[Unit]
Description=GPG Agent Forwarding Bridge
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/socat UNIX-LISTEN:/run/user/1000/gnupg/S.gpg-agent,fork TCP:127.0.0.1:9999
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
```

**`.gnupg/gpg.conf`** - GPG configuration:
```conf
use-agent
pinentry-mode loopback
```

**`.gnupg/gpg-agent.conf`** - GPG agent configuration:
```conf
default-cache-ttl 604800
max-cache-ttl 604800
enable-ssh-support
```

## Installation

### Prerequisites

1. **socat** must be installed on BeaglePlay:
   ```bash
   ssh bp 'sudo apt-get update && sudo apt-get install -y socat'
   ```

### Deploy Configuration

1. **Copy files to BeaglePlay**:
   ```bash
   ./scripts/deploy.sh
   ```

2. **Enable and start the systemd service**:
   ```bash
   ssh bp 'systemctl --user enable --now gpg-agent-forward.service'
   ```

3. **Verify service is running**:
   ```bash
   ssh bp 'systemctl --user status gpg-agent-forward.service'
   ```

### Update Local SSH Config

Add the RemoteForward line to your `~/.ssh/config`:
```ssh
Host bp
  RemoteForward 127.0.0.1:9999 /run/user/1000/gnupg/S.gpg-agent
```

## Testing

Test GPG signing on BeaglePlay:
```bash
ssh bp 'cd ~/.config/nvim && git commit --allow-empty -m "Test GPG forwarding"'
```

Verify the signature:
```bash
ssh bp 'cd ~/.config/nvim && git log -1 --show-signature'
```

You should see:
```
gpg: Good signature from "Your Name <your@email.com>"
```

## Troubleshooting

### Service Not Running

Check service status:
```bash
ssh bp 'systemctl --user status gpg-agent-forward.service'
```

View service logs:
```bash
ssh bp 'journalctl --user -u gpg-agent-forward.service -f'
```

### GPG Signing Fails

1. **Verify TCP forwarding**:
   ```bash
   ssh bp 'netstat -tln | grep 9999'
   ```

2. **Test socket connection**:
   ```bash
   ssh bp 'ls -la /run/user/1000/gnupg/S.gpg-agent'
   ```

3. **Check GPG agent locally**:
   ```bash
   gpg-connect-agent /bye
   ```

### Restart Everything

If issues persist, restart the forwarding:
```bash
# On BeaglePlay
ssh bp 'systemctl --user restart gpg-agent-forward.service'

# Reconnect SSH to re-establish port forwarding
ssh bp
```

## Security Notes

- Your private GPG key **never leaves** your local machine
- The forwarding only works while SSH is connected
- TCP port 9999 only listens on localhost (127.0.0.1) - not accessible from network
- The systemd service runs as your user (not root)
- Keys are cached for 7 days as configured in `gpg-agent.conf`

## Why TCP Instead of Unix Socket Forwarding?

SSH supports both Unix socket and TCP port forwarding, but:
- **Unix socket forwarding** requires specific kernel features and can fail with Tailscale SSH
- **TCP port forwarding** is more reliable and universally supported
- The socat bridge pattern is a common workaround when direct socket forwarding fails
- Security is equivalent since TCP only listens on localhost

## See Also

- [GPG Agent Forwarding](https://wiki.gnupg.org/AgentForwarding)
- [SSH Port Forwarding](https://www.ssh.com/academy/ssh/tunneling/example)
- [socat Documentation](http://www.dest-unreach.org/socat/)
