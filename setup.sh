#!/bin/bash
# VPS Setup Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create directories
mkdir -p /usr/local/sbin
mkdir -p /etc/xray
mkdir -p /usr/local/etc/xray
mkdir -p /root/autoscript

# Copy menu scripts
cp -rf menu/* /usr/local/sbin/
chmod +x /usr/local/sbin/*

# Install core components
bash xray/xray-setup.sh
bash ssh/ssh-setup.sh
bash trojan/trojan-setup.sh

# Configure services
systemctl restart nginx
systemctl enable nginx

# Setup completed
clear
echo -e "${GREEN}Setup completed!${NC}"
echo -e "\nAvailable commands:"
echo -e "${YELLOW}menu${NC}          - Main menu"
echo -e "${YELLOW}ssh-manager${NC}    - SSH manager"
echo -e "${YELLOW}xray-manager${NC}   - XRAY manager" 
echo -e "${YELLOW}trojan-manager${NC} - Trojan manager"
echo -e "${YELLOW}ws-manager${NC}     - WebSocket manager"

echo -e "\nDefault ports:"
echo -e "SSH: 22"
echo -e "XRAY: 443"
echo -e "Nginx: 80"