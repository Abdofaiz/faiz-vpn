#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
REPO_URL="https://github.com/Abdofaiz/faiz-vpn"
BRANCH="main"
TEMP_DIR="/tmp/vpn-install"

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}            ${CYAN}VPN SCRIPT DOWNLOADER${NC}                 ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Check root
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Install required packages
echo -e "Installing required packages..."
apt-get update
apt-get install -y git wget unzip

# Create temp directory
rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR
cd $TEMP_DIR

# Download repository
echo -e "Downloading VPN scripts..."
wget -q "${REPO_URL}/archive/refs/heads/${BRANCH}.zip" -O vpn.zip
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to download scripts${NC}"
    exit 1
fi

# Extract files
echo -e "Extracting files..."
unzip -q vpn.zip
cd faiz-vpn-${BRANCH}

# Run installer
echo -e "Starting installation..."
chmod +x install.sh
./install.sh

# Cleanup
cd /root
rm -rf $TEMP_DIR 