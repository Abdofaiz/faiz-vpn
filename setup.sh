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
cp -rf faiz-vpn-main/menu/* /usr/local/vpsmgr/menu/
rm -rf menu.zip faiz-vpn-main

# Install menu scripts
echo -e "\n${BLUE}[4/7]${NC} Installing menu scripts..."
cd /usr/local/vpsmgr/menu
chmod +x *
cp * /usr/local/sbin/

# Install protocols
echo -e "\n${BLUE}[5/7]${NC} Installing protocols..."
bash /usr/local/vpsmgr/menu/xray-install
bash /usr/local/vpsmgr/menu/ssh-install
bash /usr/local/vpsmgr/menu/trojan-install

# Configure services
echo -e "\n${BLUE}[6/7]${NC} Configuring services..."
systemctl restart nginx
systemctl enable nginx
systemctl restart xray
systemctl enable xray

# Install API and utils
echo -e "\n${BLUE}[7/7]${NC} Installing additional components..."
cd /usr/local/vpsmgr
cp -rf api/* /usr/local/vpsmgr/api/
cp -rf utils/* /usr/local/vpsmgr/utils/
pip3 install -r api/requirements.txt

# Update PATH
echo 'PATH="/usr/local/vpsmgr/menu:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' > /etc/environment
source /etc/environment

echo -e "${GREEN}Installation completed!${NC}"
echo -e "\nYou can now use the following commands:"
echo -e "${YELLOW}menu${NC} - Main menu"
echo -e "${YELLOW}ssh${NC} - SSH manager"
echo -e "${YELLOW}xray${NC} - XRAY manager"
echo -e "${YELLOW}trojan${NC} - Trojan manager"
echo -e "\nDefault ports:"
echo -e "SSH: 22"
echo -e "XRAY: 443"
echo -e "Nginx: 80"