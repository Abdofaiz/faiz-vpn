#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check root
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi

# Check OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        echo -e "${RED}This script only works on Ubuntu${NC}"
        exit 1
    fi
fi

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}             ${CYAN}VPN SCRIPT INSTALLER${NC}                  ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Update system
echo -e "${CYAN}[INFO]${NC} Updating system..."
apt-get update
apt-get upgrade -y

# Install essential packages
echo -e "${CYAN}[INFO]${NC} Installing essential packages..."
apt-get install -y wget curl git unzip

# Set timezone
echo -e "${CYAN}[INFO]${NC} Setting timezone..."
ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# Disable IPv6
echo -e "${CYAN}[INFO]${NC} Disabling IPv6..."
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p

# Get public IP
echo -e "${CYAN}[INFO]${NC} Getting public IP..."
MYIP=$(wget -qO- ipinfo.io/ip)
echo "IP=$MYIP" > /var/lib/scrz-prem/ipvps.conf

# Download installer
echo -e "${CYAN}[INFO]${NC} Downloading VPN installer..."
wget -O install-vpn.sh "https://raw.githubusercontent.com/yourusername/yourrepo/main/install-vpn.sh"
chmod +x install-vpn.sh

# Run installer
echo -e "${CYAN}[INFO]${NC} Running VPN installer..."
./install-vpn.sh

# Cleanup
rm -f install-vpn.sh
rm -f setup.sh

echo -e "${GREEN}Installation completed!${NC}"
echo -e "Type ${GREEN}menu${NC} to access VPN Manager" 