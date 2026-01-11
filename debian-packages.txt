# uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
sudo tailscale set --operator=debian
tailscale set --ssh=true

# Docker
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker debian
sudo systemctl enable --now docker

# Standard package repo packages
sudo apt install -y \
  zsh \
  git \
  lsd grc \
  tmux \
  direnv \
  fzf fd-find ripgrep \
  neovim ruby-neovim python3-pynvim \
  ghc cabal-install \
  firmware-ti-connectivity \
  tealdeer \
  python3 python3-pip \
  nodejs npm

