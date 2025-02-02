#!/bin/bash
# VPS Installation Script v03.49.25

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check root
if [ "${EUID}" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# Check OS
if [[ "$(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g')" != "ubuntu" ]]; then
    echo -e "${RED}This script only works on Ubuntu${NC}"
    exit 1
fi

clear
echo -e "${BLUE}=====================================${NC}"
echo -e "${GREEN}     VPS Installation Script        ${NC}"
echo -e "${BLUE}=====================================${NC}"

# Update system
echo -e "\n${BLUE}[1/7]${NC} Updating system..."
apt update
apt upgrade -y
apt install -y wget curl jq unzip

# Install dependencies
echo -e "\n${BLUE}[2/7]${NC} Installing dependencies..."
apt install -y nginx certbot python3-certbot-nginx
apt install -y vnstat fail2ban
apt install -y iptables iptables-persistent
apt install -y bzip2 gzip coreutils screen

# Download script files
echo -e "\n${BLUE}[3/7]${NC} Downloading script files..."
wget -q -O /tmp/script.zip "https://github.com/yourusername/autoscript/archive/main.zip"
unzip -qq /tmp/script.zip -d /tmp/
rm -f /tmp/script.zip
mkdir -p /root/autoscript
cp -rf /tmp/autoscript-main/* /root/autoscript/
rm -rf /tmp/autoscript-main

# Install menu scripts
echo -e "\n${BLUE}[4/7]${NC} Installing menu scripts..."
mkdir -p /usr/local/sbin
cp -rf /root/autoscript/menu/* /usr/local/sbin/
chmod +x /usr/local/sbin/*

# Install protocols
echo -e "\n${BLUE}[5/7]${NC} Installing protocols..."
bash "/root/autoscript/xray/xray-setup.sh"
bash "/root/autoscript/ssh/ssh-setup.sh"
bash "/root/autoscript/trojan/trojan-setup.sh"

# Configure services
echo -e "\n${BLUE}[6/7]${NC} Configuring services..."
systemctl restart nginx
systemctl enable nginx

# Install additional components
echo -e "\n${BLUE}[7/7]${NC} Installing additional components..."
bash "/root/autoscript/websocket/ws-setup.sh"
bash "/root/autoscript/backup/backup-setup.sh"

# Cleanup
rm -f /root/install.sh
history -c
echo "clear" >> ~/.bash_profile
echo "menu" >> ~/.bash_profile

clear
echo -e "${GREEN}Installation completed!${NC}"
echo -e "\nType ${YELLOW}menu${NC} to access VPS Manager"

echo -e "\nDefault ports:"
echo -e "SSH: 22"
echo -e "XRAY: 443"
echo -e "Nginx: 80" 