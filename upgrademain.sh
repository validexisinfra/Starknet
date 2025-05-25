#!/bin/bash

set -e

echo "Pulling latest Pathfinder image..."
sudo docker pull eqlabs/pathfinder

echo "Stopping existing Pathfinder container (if running)..."
sudo docker stop pathfinder || true

echo "🗑 Removing old Pathfinder container..."
sudo docker rm pathfinder || true

echo "Starting new Pathfinder container..."
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

echo "✅ Pathfinder updated and running!"

echo ""
echo "📄 To check logs, run:"
echo "sudo docker logs pathfinder -fn100"
