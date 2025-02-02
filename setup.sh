#!/bin/bash
# VPS Installation Script

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

clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "         INSTALLING VPS MANAGER 03.49.25"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Create directories
echo -e "\n${BLUE}[1/7]${NC} Creating directories..."
mkdir -p /usr/local/vpsmgr/{menu,api,backup,boot,client,dropbear,l2tp,ohp,openvpn,slowdns,ssh,trojango,udpgw,utils,websocket,xray}

# Install dependencies
echo -e "\n${BLUE}[2/7]${NC} Installing dependencies..."
apt update
apt install -y wget curl git unzip python3 python3-pip nginx certbot

# Download menu files
echo -e "\n${BLUE}[3/7]${NC} Downloading menu files..."
cd /usr/local/vpsmgr
wget -O menu.zip "https://github.com/Abdofaiz/faiz-vpn/archive/refs/heads/main.zip"
unzip menu.zip

# Install menu scripts
echo -e "\n${BLUE}[4/7]${NC} Installing menu scripts..."
cd /usr/local/vpsmgr
cp -rf "faiz-vpn-main/menu 03.49.25/"* /usr/local/sbin/
chmod +x /usr/local/sbin/*

# Install protocols
echo -e "\n${BLUE}[5/7]${NC} Installing protocols..."
bash "faiz-vpn-main/xray 03.49.25/xray-setup.sh"
bash "faiz-vpn-main/ssh 03.49.25/ssh-setup.sh"
bash "faiz-vpn-main/trojango 03.49.25/trojan-setup.sh"

# Configure services
echo -e "\n${BLUE}[6/7]${NC} Configuring services..."
systemctl restart nginx
systemctl enable nginx

# Install additional components
echo -e "\n${BLUE}[7/7]${NC} Installing additional components..."
cp -rf "faiz-vpn-main/api/"* /usr/local/vpsmgr/api/
cp -rf "faiz-vpn-main/utils/"* /usr/local/vpsmgr/utils/
cp -rf "faiz-vpn-main/websocket 03.49.25/"* /usr/local/vpsmgr/websocket/
cp -rf "faiz-vpn-main/slowdns/"* /usr/local/vpsmgr/slowdns/
cp -rf "faiz-vpn-main/openvpn/"* /usr/local/vpsmgr/openvpn/
cp -rf "faiz-vpn-main/l2tp/"* /usr/local/vpsmgr/l2tp/
cp -rf "faiz-vpn-main/dropbear/"* /usr/local/vpsmgr/dropbear/

# Cleanup
rm -rf menu.zip faiz-vpn-main

# Update PATH
echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' > /etc/environment
source /etc/environment

echo -e "${GREEN}Installation completed!${NC}"
echo -e "\nAvailable commands:"
echo -e "${YELLOW}menu${NC}          - Main menu"
echo -e "${YELLOW}ssh-manager${NC}    - SSH manager"
echo -e "${YELLOW}xray-manager${NC}   - XRAY manager"
echo -e "${YELLOW}trojan-manager${NC} - Trojan manager"
echo -e "${YELLOW}ws-manager${NC}     - WebSocket manager"
echo -e "${YELLOW}openvpn${NC}        - OpenVPN manager"
echo -e "${YELLOW}l2tp-manager${NC}   - L2TP manager"
echo -e "${YELLOW}slowdns-manager${NC} - SlowDNS manager"
echo -e "${YELLOW}backup-manager${NC}  - Backup manager"
echo -e "${YELLOW}domain-manager${NC}  - Domain manager"
echo -e "${YELLOW}port-manager${NC}    - Port manager"
echo -e "${YELLOW}limit-manager${NC}   - Limit manager"
echo -e "${YELLOW}user${NC}           - User management"
echo -e "${YELLOW}monitor${NC}        - Server monitor"
echo -e "${YELLOW}speedtest${NC}      - Speed test"
echo -e "${YELLOW}update${NC}         - Update script"

echo -e "\nDefault ports:"
echo -e "SSH: 22"
echo -e "XRAY: 443"
echo -e "Nginx: 80"