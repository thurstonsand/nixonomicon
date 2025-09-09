#!/bin/bash

# MyAnonamouse Dynamic Seedbox IP Setup Script
# This script automates the setup process for MAM dynamic seedbox IP

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}MyAnonamouse Dynamic Seedbox IP Setup${NC}"
echo "========================================"

# Function to run commands on the NAS
run_on_nas() {
    ssh truenas "$1"
}

# Function to run commands inside the qbittorrent container
run_in_container() {
    run_on_nas "docker exec -i qbittorrent $1"
}

# Step 1: Get the container's IP address
echo -e "\n${YELLOW}Step 1: Getting container IP address...${NC}"
CONTAINER_IP=$(run_in_container "curl -s http://whatismyip.akamai.com")

if [ -z "$CONTAINER_IP" ]; then
    echo -e "${RED}Failed to get container IP address${NC}"
    exit 1
fi

echo -e "${GREEN}Container IP: $CONTAINER_IP${NC}"

# Step 2: Prompt for manual steps
echo -e "\n${YELLOW}Step 2: Manual Configuration Required${NC}"
echo "Please complete these steps in your browser:"
echo "1. Visit: https://www.myanonamouse.net/preferences/index.php?view=security"
echo "2. Add entry for IP address: $CONTAINER_IP"
echo "3. Navigate back to main screen"
echo "4. Check 'Allow session to set dynamic seedbox IP'"
echo "5. Click 'View IP locked session cookie'"
echo "6. Copy the mam_id value"

echo -e "\n${BLUE}Press Enter when you have completed the above steps and have the mam_id ready...${NC}"
read -r

# Step 3: Get the session ID from user
echo -e "\n${YELLOW}Step 3: Enter Session ID${NC}"
echo -n "Please enter your mam_id (session ID): "
read -r SESSION_ID

if [ -z "$SESSION_ID" ]; then
    echo -e "${RED}Session ID cannot be empty${NC}"
    exit 1
fi

# Step 4: Set dynamic seedbox IP
echo -e "\n${YELLOW}Step 4: Setting dynamic seedbox IP...${NC}"
RESPONSE=$(run_in_container "curl -s -b 'mam_id=$SESSION_ID' https://t.myanonamouse.net/json/dynamicSeedbox.php")

echo "Response: $RESPONSE"

if echo "$RESPONSE" | grep -q '"Success":true'; then
    echo -e "${GREEN}✓ Dynamic seedbox IP set successfully!${NC}"
else
    echo -e "${RED}✗ Failed to set dynamic seedbox IP${NC}"
    echo "Response: $RESPONSE"
    exit 1
fi

# Step 5: Instructions for final step
echo -e "\n${YELLOW}Step 5: Final Manual Step${NC}"
echo "Please complete the final step:"
echo "1. Go to your qBittorrent web interface"
echo "2. Select all torrents (or the ones you want to reannounce)"
echo "3. Right-click and select 'Force reannounce'"
echo ""
echo -e "${GREEN}Setup completed successfully!${NC}"
echo "Your container IP ($CONTAINER_IP) has been registered with MyAnonamouse."