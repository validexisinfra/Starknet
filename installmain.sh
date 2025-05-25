#!/bin/bash

set -e

# Prompt for STARKNET_RPC first
echo "Enter your Ethereum Mainnet RPC URL (e.g., from Alchemy or Infura):"
read -p "STARKNET_RPC: " STARKNET_RPC
echo "export STARKNET_RPC=${STARKNET_RPC}" >> "$HOME/.bash_profile"
source "$HOME/.bash_profile"

# Update system and install essential build tools
echo "Updating system and installing required packages..."
sudo apt -q update
sudo apt -qy install curl git jq lz4 zstd build-essential
sudo apt -qy upgrade

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
docker --version

# Install Docker Compose
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/v2.10.1/docker-compose-$(uname -s)-$(uname -m)" -o docker-compose
chmod +x docker-compose
sudo mv docker-compose /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version

# Create directory for Pathfinder data
echo "Creating directory for Pathfinder data..."
mkdir -p "$HOME/pathfinder"

# Start the Pathfinder Docker container
echo "Starting Pathfinder container..."
sudo docker run \
  --name pathfinder \
  --restart unless-stopped \
  --detach \
  -p 9545:9545 \
  --user "$(id -u):$(id -g)" \
  -e RUST_LOG=info \
  -e PATHFINDER_ETHEREUM_API_URL="$STARKNET_RPC" \
  -v "$HOME/pathfinder:/usr/share/pathfinder/data" \
  eqlabs/pathfinder

echo "✅ Setup complete. Pathfinder is now running on port 9545."

# Suggest checking logs
echo ""
echo "📄 To view Pathfinder logs in real time, run:"
echo "sudo docker logs -fn100 pathfinder"
