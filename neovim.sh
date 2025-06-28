#!/bin/bash
set -e

# Install dependencies
sudo apt update
sudo apt install -y curl git wget xclip ripgrep build-essential luarocks gzip tar unzip python3-pip python3-venv

# # Install tiktoken_core for Lua 5.1 -- only needed for copilot chat
# sudo luarocks install --lua-version 5.1 tiktoken_core

# Install nvm and npm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Install Neovim and lazygit
NVIM_VERSION="0.11.2"
arch=$(uname -m)

declare -A nvim_archives=(
  ["x86_64"]="nvim-linux-x86_64"
  ["aarch64"]="nvim-linux-arm64"
)

declare -A lazygit_archives=(
  ["x86_64"]="Linux_x86_64"
  ["aarch64"]="Linux_arm64"
)

if [[ "$arch" == "x86_64" ]]; then
  if ! grep -Fxq 'export NVIM_MODE_LUH="ws"' "$HOME/.bashrc"; then
    echo 'export NVIM_MODE_LUH="ws"' >> "$HOME/.bashrc"
    echo "Added NVIM_MODE_LUH=ws to ~/.bashrc"
  fi
fi

if [[ -n "${nvim_archives[$arch]}" && -n "${lazygit_archives[$arch]}" ]]; then
  # Install latest lazygit
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
  LAZYGIT_ARCHIVE="${lazygit_archives[$arch]}"
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_${LAZYGIT_ARCHIVE}.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit -D -t /usr/local/bin/
  rm lazygit.tar.gz lazygit

  # Install neovim
  NVIM_ARCHIVE="${nvim_archives[$arch]}"
  curl -LO "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${NVIM_ARCHIVE}.tar.gz"
  sudo rm -rf "/opt/${NVIM_ARCHIVE}"
  sudo tar -C /opt -xzf "${NVIM_ARCHIVE}.tar.gz"
  sudo ln -s "/opt/${NVIM_ARCHIVE}/bin/nvim" /usr/local/bin/nvim
  rm "${NVIM_ARCHIVE}.tar.gz"
else
  echo "Unsupported architecture: $arch"
  if [[ -z "${nvim_archives[$arch]}" ]]; then
    echo "No Neovim archive available for $arch"
  fi
  if [[ -z "${lazygit_archives[$arch]}" ]]; then
    echo "No lazygit archive available for $arch"
  fi
  exit 1
fi

echo ""
echo "--------------------------------------------------------"
echo "Setup complete! Please run 'source ~/.bashrc' or open a new terminal"
echo "for changes to environment variables (like NVIM_MODE_LUH and PATH)"
echo "to take effect."
echo "Furthermore run if needed:"
echo "nvm install stable"
echo "nvm use stable"
echo "--------------------------------------------------------"
