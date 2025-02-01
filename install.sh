#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="/usr/local/vpn-script"
CONFIG_DIR="/etc/vpn"
BOT_DIR="/etc/bot"

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}            ${CYAN}VPN SCRIPT INSTALLER${NC}                   ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Create directories
create_directories() {
    echo -e "Creating directories..."
    mkdir -p $SCRIPT_DIR/{menu,protocols,bot,security}
    mkdir -p $CONFIG_DIR/{payloads,ssl}
    mkdir -p $BOT_DIR/{backups,.config}
    mkdir -p /etc/stunnel
}

# Install dependencies
install_dependencies() {
    echo -e "Installing dependencies..."
    apt-get update
    apt-get install -y \
        python3 \
        python3-pip \
        netcat \
        openssl \
        stunnel4 \
        squid \
        jq \
        curl \
        wget \
        zip \
        unzip
    
    pip3 install websockets proxy.py
}

# Copy script files
copy_scripts() {
    echo -e "Copying script files..."
    
    # Main menu
    cp menu.sh $SCRIPT_DIR/
    cp menu-ssh.sh $SCRIPT_DIR/menu/
    cp menu-xray.sh $SCRIPT_DIR/menu/
    cp menu-argo.sh $SCRIPT_DIR/menu/
    cp menu-security.sh $SCRIPT_DIR/menu/
    cp menu-settings.sh $SCRIPT_DIR/menu/
    cp menu-backup.sh $SCRIPT_DIR/menu/
    cp menu-bot.sh $SCRIPT_DIR/menu/
    
    # Protocols
    cp protocols/ssh-http.sh $SCRIPT_DIR/protocols/
    cp protocols/ssh-ssl.sh $SCRIPT_DIR/protocols/
    cp protocols/websocket-http.sh $SCRIPT_DIR/protocols/
    cp protocols/custom-payload.sh $SCRIPT_DIR/protocols/
    
    # Bot scripts
    cp bot/register-ip.sh $SCRIPT_DIR/bot/
    cp bot/ip-lookup.sh $SCRIPT_DIR/bot/
    cp bot/cdn-check.sh $SCRIPT_DIR/bot/
    cp bot/banner-check.sh $SCRIPT_DIR/bot/
    cp bot/response-check.sh $SCRIPT_DIR/bot/
    cp bot/cert-check.sh $SCRIPT_DIR/bot/
    cp bot/bot-settings.sh $SCRIPT_DIR/bot/
    cp bot/monitor-bot.sh $SCRIPT_DIR/bot/
    cp bot/backup-bot.sh $SCRIPT_DIR/bot/
    cp bot/schedule-backup.sh $SCRIPT_DIR/bot/
    
    # Security scripts
    cp security/ban-ssh.sh $SCRIPT_DIR/security/
    cp security/ban-xray.sh $SCRIPT_DIR/security/
    cp security/unban-ssh.sh $SCRIPT_DIR/security/
    cp security/unban-xray.sh $SCRIPT_DIR/security/
    cp security/lock-ssh.sh $SCRIPT_DIR/security/
    cp security/lock-xray.sh $SCRIPT_DIR/security/
}

# Set permissions
set_permissions() {
    echo -e "Setting permissions..."
    chmod +x $SCRIPT_DIR/menu.sh
    chmod +x $SCRIPT_DIR/menu/*.sh
    chmod +x $SCRIPT_DIR/protocols/*.sh
    chmod +x $SCRIPT_DIR/bot/*.sh
    chmod +x $SCRIPT_DIR/security/*.sh
}

# Create symlinks
create_symlinks() {
    echo -e "Creating symlinks..."
    ln -sf $SCRIPT_DIR/menu.sh /usr/local/bin/menu
    ln -sf $SCRIPT_DIR/menu/menu-ssh.sh /usr/local/bin/menu-ssh
    ln -sf $SCRIPT_DIR/menu/menu-xray.sh /usr/local/bin/menu-xray
    ln -sf $SCRIPT_DIR/menu/menu-argo.sh /usr/local/bin/menu-argo
    ln -sf $SCRIPT_DIR/menu/menu-security.sh /usr/local/bin/menu-security
    ln -sf $SCRIPT_DIR/menu/menu-settings.sh /usr/local/bin/menu-settings
    ln -sf $SCRIPT_DIR/menu/menu-backup.sh /usr/local/bin/menu-backup
    ln -sf $SCRIPT_DIR/menu/menu-bot.sh /usr/local/bin/menu-bot
}

# Configure services
configure_services() {
    echo -e "Configuring services..."
    
    # Configure Squid
    if [ -f "/etc/squid/squid.conf" ]; then
        cp /etc/squid/squid.conf /etc/squid/squid.conf.bak
        cp squid.conf /etc/squid/squid.conf
        systemctl restart squid
    fi
    
    # Configure Stunnel
    if [ -f "/etc/stunnel/stunnel.conf" ]; then
        cp /etc/stunnel/stunnel.conf /etc/stunnel/stunnel.conf.bak
        openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
            -subj "/C=US/ST=State/L=Location/O=Organization/CN=CommonName" \
            -keyout /etc/stunnel/stunnel.pem -out /etc/stunnel/stunnel.pem
        chmod 600 /etc/stunnel/stunnel.pem
    fi
}

# Main installation
echo -e "Starting installation..."

# Check root
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Execute installation steps
create_directories
install_dependencies
copy_scripts
set_permissions
create_symlinks
configure_services

# Final setup
echo -e "\n${GREEN}Installation completed!${NC}"
echo -e "\nYou can now:"
echo -e "1. Run ${GREEN}menu${NC} to access the main menu"
echo -e "2. Configure your bot settings in ${GREEN}menu-bot${NC}"
echo -e "3. Set up your VPN configurations in ${GREEN}menu-ssh${NC}"
echo -e ""
echo -e "${YELLOW}Note: Make sure to configure your bot token and admin ID before using bot features${NC}"

# Optional: Run menu after installation
read -p "Would you like to run the menu now? [y/n]: " run_menu
if [[ $run_menu =~ ^[Yy]$ ]]; then
    menu
fi 