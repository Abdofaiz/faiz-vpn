#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
REPO_RAW="https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main"
SCRIPT_DIR="/usr/local/vpn-script"

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}            ${CYAN}VPN SCRIPT INSTALLER${NC}                   ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Check root
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Create directories
echo -e "Creating directories..."
mkdir -p "$SCRIPT_DIR"/{menu,protocols,bot,security}
mkdir -p /etc/vpn/{payloads,ssl}
mkdir -p /etc/bot/{backups,.config}

# Download function
download_script() {
    local file=$1
    local dest=$2
    echo -e "Downloading $file..."
    wget -q "$REPO_RAW/$file" -O "$dest" || {
        echo -e "${RED}Failed to download $file${NC}"
        return 1
    }
    chmod +x "$dest"
    echo -e "${GREEN}Downloaded $file${NC}"
}

# Download main scripts
download_script "menu.sh" "$SCRIPT_DIR/menu.sh"

# Download menu scripts
for script in menu-ssh.sh menu-xray.sh menu-bot.sh menu-security.sh menu-settings.sh menu-backup.sh; do
    download_script "menu/$script" "$SCRIPT_DIR/menu/$script"
done

# Download protocol scripts
for script in ssh.sh websocket.sh xray.sh; do
    download_script "protocols/$script" "$SCRIPT_DIR/protocols/$script"
done

# Download bot scripts
for script in register-ip.sh ip-lookup.sh; do
    download_script "bot/$script" "$SCRIPT_DIR/bot/$script"
done

# Download config files
download_script "squid.conf" "/etc/squid/squid.conf"

# Create symlinks
echo -e "Creating symlinks..."
ln -sf "$SCRIPT_DIR/menu.sh" /usr/local/bin/menu
ln -sf "$SCRIPT_DIR/menu/menu-ssh.sh" /usr/local/bin/menu-ssh
ln -sf "$SCRIPT_DIR/menu/menu-xray.sh" /usr/local/bin/menu-xray
ln -sf "$SCRIPT_DIR/menu/menu-bot.sh" /usr/local/bin/menu-bot
ln -sf "$SCRIPT_DIR/menu/menu-security.sh" /usr/local/bin/menu-security
ln -sf "$SCRIPT_DIR/menu/menu-settings.sh" /usr/local/bin/menu-settings
ln -sf "$SCRIPT_DIR/menu/menu-backup.sh" /usr/local/bin/menu-backup

# Install dependencies
echo -e "Installing dependencies..."
apt-get update
apt-get install -y \
    python3 \
    python3-pip \
    netcat \
    openssl \
    stunnel4 \
    squid \
    curl \
    wget

# Configure services
echo -e "Configuring services..."
systemctl restart squid

# Final setup
echo -e "\n${GREEN}Installation completed!${NC}"
echo -e "\nYou can now:"
echo -e "1. Run ${GREEN}menu${NC} to access the main menu"
echo -e "2. Configure your bot settings in ${GREEN}menu-bot${NC}"
echo -e "3. Set up your VPN configurations in ${GREEN}menu-ssh${NC}"

# Run menu
echo -e ""
read -p "Would you like to run the menu now? [y/n]: " run_menu
if [[ $run_menu =~ ^[Yy]$ ]]; then
    menu
fi 