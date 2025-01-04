#!/bin/zsh -ex

# Function to create a network if it does not exist
create_network() {
  local network_name=$1
  local subnet=$2
  local gateway=$3
  local ip_range=$4
  local parent=$5

  if docker network inspect $network_name &>/dev/null; then
    echo "Network '$network_name' already exists. Skipping creation."
  else
    echo "Creating network '$network_name'..."
    docker network create \
      --driver macvlan \
      --subnet=$subnet \
      --gateway=$gateway \
      --ip-range=$ip_range \
      -o parent=$parent \
      $network_name
    if [ $? -eq 0 ]; then
      echo "Network '$network_name' created successfully."
    else
      echo "Failed to create network '$network_name'." >&2
    fi
  fi
}

# Create default network
# Skipping 'default' network creation as it conflicts with Docker's predefined default network.
create_network trusted 192.168.1.0/24 192.168.1.1 192.168.1.224/27 br0.1

# Create IoT network
create_network iot 192.168.3.0/24 192.168.3.1 192.168.3.224/27 br0.2

# Create external network
create_network external 192.168.5.0/24 192.168.5.1 192.168.5.224/27 br0.3

# Create personal network
create_network personal 192.168.6.0/24 192.168.6.1 192.168.6.224/27 br0.4
