#!/bin/bash
# Main Installation Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check root
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi

# Update system
echo -e "${BLUE}Updating system...${NC}"
apt update && apt upgrade -y

# Install dependencies
echo -e "${BLUE}Installing dependencies...${NC}"
apt install -y curl wget jq unzip nginx python3 python3-pip

# Clone repository
echo -e "${BLUE}Downloading scripts...${NC}"
wget https://github.com/yourusername/autoscript/archive/main.zip
unzip main.zip
cd autoscript-main

# Run setup scripts
echo -e "${BLUE}Running setup scripts...${NC}"
chmod +x setup/*.sh
./setup/main-setup.sh
./setup/ssh-setup.sh
./setup/xray-setup.sh
./setup/ws-setup.sh

# Install menu
echo -e "${BLUE}Installing menu...${NC}"
cp menu/* /usr/local/bin/
chmod +x /usr/local/bin/menu*

# Setup API server
echo -e "${BLUE}Setting up API server...${NC}"
pip3 install -r api/requirements.txt
cp api/server.py /usr/local/bin/
cp api/account_manager.py /usr/local/bin/

# Run tests
echo -e "${BLUE}Running tests...${NC}"
./test-install.sh

echo -e "${GREEN}Installation complete!${NC}"
echo -e "Use ${YELLOW}menu${NC} command to manage your VPS" 