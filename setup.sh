#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Repository URL
REPO="https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main"
SCRIPT_DIR="/usr/local/vpn-script"

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

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}            ${CYAN}VPN SCRIPT INSTALLER${NC}                  ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Create directories
mkdir -p "$SCRIPT_DIR"/{install/{core,protocols},menu,ssh,xray,bot}

# Download installation files
echo -e "${CYAN}Downloading installation files...${NC}"
wget -O $SCRIPT_DIR/install/install.sh "$REPO/install/install.sh"
wget -O $SCRIPT_DIR/install/core/packages.sh "$REPO/install/core/packages.sh"
wget -O $SCRIPT_DIR/install/core/domain.sh "$REPO/install/core/domain.sh"
wget -O $SCRIPT_DIR/install/protocols/ssh.sh "$REPO/install/protocols/ssh.sh"

# Set permissions
chmod +x $SCRIPT_DIR/install/*.sh
chmod +x $SCRIPT_DIR/install/core/*.sh
chmod +x $SCRIPT_DIR/install/protocols/*.sh

# Run installer
bash $SCRIPT_DIR/install/install.sh

# Create directory structure
echo -e "${CYAN}Creating directory structure...${NC}"
mkdir -p /etc/{ssh,xray,vpn,bot}
mkdir -p /etc/vpn/{payloads,ssl}
mkdir -p /etc/bot/{backups,.config}
mkdir -p /var/lib/scrz-prem

# Download menu scripts
echo -e "${CYAN}Downloading menu scripts...${NC}"
cd /usr/local/vpn-script/menu
wget -O menu.sh "$REPO/menu.sh"
wget -O menu-ssh.sh "$REPO/menu/menu-ssh.sh"
wget -O menu-xray.sh "$REPO/menu/menu-xray.sh"
wget -O menu-vmess.sh "$REPO/menu/menu-vmess.sh"
wget -O menu-vless.sh "$REPO/menu/menu-vless.sh"
wget -O menu-trojan.sh "$REPO/menu/menu-trojan.sh"
wget -O menu-argo.sh "$REPO/menu/menu-argo.sh"
wget -O menu-security.sh "$REPO/menu/menu-security.sh"
wget -O menu-settings.sh "$REPO/menu/menu-settings.sh"
wget -O menu-backup.sh "$REPO/menu/menu-backup.sh"
wget -O menu-bot.sh "$REPO/menu/menu-bot.sh"

# Download SSH scripts
echo -e "${CYAN}Downloading SSH scripts...${NC}"
cd /usr/local/vpn-script/ssh
wget -O add-ssh.sh "$REPO/ssh/add-ssh.sh"
wget -O del-ssh.sh "$REPO/ssh/del-ssh.sh"
wget -O extend-ssh.sh "$REPO/ssh/extend-ssh.sh"
wget -O cek-ssh.sh "$REPO/ssh/cek-ssh.sh"

# Download XRAY scripts
echo -e "${CYAN}Downloading XRAY scripts...${NC}"
cd /usr/local/vpn-script/xray
wget -O add-ws.sh "$REPO/xray/add-ws.sh"
wget -O add-grpc.sh "$REPO/xray/add-grpc.sh"
wget -O add-tcp.sh "$REPO/xray/add-tcp.sh"
wget -O del-user.sh "$REPO/xray/del-user.sh"
wget -O extend-user.sh "$REPO/xray/extend-user.sh"
wget -O cek-user.sh "$REPO/xray/cek-user.sh"

# Download bot scripts
echo -e "${CYAN}Downloading bot scripts...${NC}"
cd /usr/local/vpn-script/bot
wget -O register-ip.sh "$REPO/bot/register-ip.sh"
wget -O ip-lookup.sh "$REPO/bot/ip-lookup.sh"
wget -O monitor-bot.sh "$REPO/bot/monitor-bot.sh"
wget -O backup-bot.sh "$REPO/bot/backup-bot.sh"

# Set permissions
echo -e "${CYAN}Setting permissions...${NC}"
chmod +x /usr/local/vpn-script/menu/*.sh
chmod +x /usr/local/vpn-script/ssh/*.sh
chmod +x /usr/local/vpn-script/xray/*.sh
chmod +x /usr/local/vpn-script/bot/*.sh

# Create symlinks
echo -e "${CYAN}Creating symlinks...${NC}"
ln -sf /usr/local/vpn-script/menu/menu.sh /usr/local/bin/menu
ln -sf /usr/local/vpn-script/menu/menu-ssh.sh /usr/local/bin/menu-ssh
ln -sf /usr/local/vpn-script/menu/menu-xray.sh /usr/local/bin/menu-xray
ln -sf /usr/local/vpn-script/menu/menu-vmess.sh /usr/local/bin/menu-vmess
ln -sf /usr/local/vpn-script/menu/menu-vless.sh /usr/local/bin/menu-vless
ln -sf /usr/local/vpn-script/menu/menu-trojan.sh /usr/local/bin/menu-trojan
ln -sf /usr/local/vpn-script/menu/menu-argo.sh /usr/local/bin/menu-argo
ln -sf /usr/local/vpn-script/menu/menu-security.sh /usr/local/bin/menu-security
ln -sf /usr/local/vpn-script/menu/menu-settings.sh /usr/local/bin/menu-settings
ln -sf /usr/local/vpn-script/menu/menu-backup.sh /usr/local/bin/menu-backup
ln -sf /usr/local/vpn-script/menu/menu-bot.sh /usr/local/bin/menu-bot

# Install dependencies
echo -e "${CYAN}Installing dependencies...${NC}"
apt-get update
apt-get install -y curl wget jq uuid-runtime socat

# Create version file
echo "1.0.0" > /home/ver

echo -e "${GREEN}Installation completed!${NC}"
echo -e "Type ${GREEN}menu${NC} to access VPN Manager" 