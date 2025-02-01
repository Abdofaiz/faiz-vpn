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
BOT_DIR="$SCRIPT_DIR/bot"
MENU_DIR="$SCRIPT_DIR/menu"
PROTO_DIR="$SCRIPT_DIR/protocols"

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
mkdir -p "$MENU_DIR" "$PROTO_DIR" "$BOT_DIR" "$SCRIPT_DIR/security"
mkdir -p /etc/vpn/{payloads,ssl}
mkdir -p /etc/bot/{backups,.config}

# Download function
download_script() {
    local file="$1"
    local dest="$2"
    echo -e "Downloading $file..."
    mkdir -p "$(dirname "$dest")"
    
    wget -q "$REPO_RAW/$file" -O "$dest"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to download $file${NC}"
        return 1
    fi
    
    chmod +x "$dest"
    if [ ! -x "$dest" ]; then
        echo -e "${RED}Failed to set permissions for $dest${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Downloaded $file${NC}"
}

# Create symlink function
create_symlink() {
    local src="$1"
    local dest="$2"
    ln -sf "$src" "$dest"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to create symlink: $dest${NC}"
        return 1
    fi
}

# Download main scripts
download_script "menu.sh" "$SCRIPT_DIR/menu.sh"

# Download menu scripts
for script in menu-ssh.sh menu-xray.sh menu-bot.sh menu-security.sh menu-settings.sh menu-backup.sh; do
    download_script "menu/$script" "$MENU_DIR/$script"
done

# Download protocol scripts
for script in ssh.sh websocket.sh xray.sh; do
    download_script "protocols/$script" "$PROTO_DIR/$script"
done

# Download bot scripts
for script in register-ip.sh ip-lookup.sh bot-settings.sh cdn-check.sh banner-check.sh \
              response-check.sh cert-check.sh monitor-bot.sh backup-bot.sh schedule-backup.sh; do
    download_script "bot/$script" "$BOT_DIR/$script"
done

# Download config files
download_script "squid.conf" "/etc/squid/squid.conf"

# Create symlinks
echo -e "Creating symlinks..."
mkdir -p /usr/local/bin

create_symlink "$SCRIPT_DIR/menu.sh" "/usr/local/bin/menu"
create_symlink "$MENU_DIR/menu-ssh.sh" "/usr/local/bin/menu-ssh"
create_symlink "$MENU_DIR/menu-xray.sh" "/usr/local/bin/menu-xray"
create_symlink "$MENU_DIR/menu-bot.sh" "/usr/local/bin/menu-bot"
create_symlink "$MENU_DIR/menu-security.sh" "/usr/local/bin/menu-security"
create_symlink "$MENU_DIR/menu-settings.sh" "/usr/local/bin/menu-settings"
create_symlink "$MENU_DIR/menu-backup.sh" "/usr/local/bin/menu-backup"

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