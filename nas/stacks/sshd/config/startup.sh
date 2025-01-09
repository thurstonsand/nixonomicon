#!/bin/bash
set -e

echo "Running startup script..."

# 1. Install system dependencies
echo "Installing system dependencies..."
apk add --no-cache curl git

git config --global --add safe.directory /config/Develop/nixonomicon

# 2. Install nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux \
  --extra-conf "sandbox = false" \
  --init none \
  --no-confirm

export PATH="${PATH}:/nix/var/nix/profiles/default/bin"
cd /config/Develop/nixonomicon && nix run . -- switch --flake .#truenas-shell

# Execute the original entrypoint with the original command
exec "$@"
