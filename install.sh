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

# Add at the beginning after colors
VERSION="1.0.0"
REPO_URL="https://github.com/Abdofaiz/faiz-vpn"
REPO_BRANCH="main"

# Add at beginning of script
MODE="install"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --update)
            MODE="update"
            shift
            ;;
        --uninstall)
            MODE="uninstall"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}            ${CYAN}VPN SCRIPT INSTALLER${NC}                   ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Create directories
create_directories() {
    echo -e "Creating directories..."
    
    # Remove existing directories if they exist
    rm -rf $SCRIPT_DIR
    
    # Create fresh directories
    mkdir -p $SCRIPT_DIR/{menu,protocols,bot,security}
    mkdir -p $CONFIG_DIR/{payloads,ssl}
    mkdir -p $BOT_DIR/{backups,.config}
    mkdir -p /etc/stunnel
    
    # Verify directories were created
    for dir in "$SCRIPT_DIR" "$CONFIG_DIR" "$BOT_DIR"; do
        if [ ! -d "$dir" ]; then
            echo -e "${RED}Failed to create directory: $dir${NC}"
            exit 1
        fi
    done
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
    
    # Check if source files exist
    if [ ! -f "menu.sh" ]; then
        echo -e "${RED}Error: menu.sh not found in current directory${NC}"
        exit 1
    fi
    
    # Main menu
    cp menu.sh $SCRIPT_DIR/ || {
        echo -e "${RED}Failed to copy menu.sh${NC}"
        exit 1
    }
    
    # Create menu directory if it doesn't exist
    mkdir -p $SCRIPT_DIR/menu
    
    # Copy menu scripts with error checking
    for menu_script in menu-*.sh; do
        if [ -f "$menu_script" ]; then
            cp "$menu_script" "$SCRIPT_DIR/menu/" || {
                echo -e "${RED}Failed to copy $menu_script${NC}"
                exit 1
            }
        fi
    done
    
    # Create and copy to other directories
    for dir in protocols bot security; do
        mkdir -p "$SCRIPT_DIR/$dir"
        if [ -d "$dir" ]; then
            cp "$dir"/*.sh "$SCRIPT_DIR/$dir/" 2>/dev/null || {
                echo -e "${YELLOW}Warning: No scripts found in $dir directory${NC}"
            }
        fi
    done
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
    # Create bin directory if it doesn't exist
    mkdir -p /usr/local/bin
    
    # Create symlinks with absolute paths
    ln -sf $SCRIPT_DIR/menu.sh /usr/local/bin/menu
    ln -sf $SCRIPT_DIR/menu/menu-ssh.sh /usr/local/bin/menu-ssh
    ln -sf $SCRIPT_DIR/menu/menu-xray.sh /usr/local/bin/menu-xray
    ln -sf $SCRIPT_DIR/menu/menu-argo.sh /usr/local/bin/menu-argo
    ln -sf $SCRIPT_DIR/menu/menu-security.sh /usr/local/bin/menu-security
    ln -sf $SCRIPT_DIR/menu/menu-settings.sh /usr/local/bin/menu-settings
    ln -sf $SCRIPT_DIR/menu/menu-backup.sh /usr/local/bin/menu-backup
    ln -sf $SCRIPT_DIR/menu/menu-bot.sh /usr/local/bin/menu-bot
    
    # Make sure all scripts are executable
    chmod +x /usr/local/bin/menu*
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

# Add new function for updates
check_update() {
    echo -e "Checking for updates..."
    
    # Get latest version from repo
    latest_ver=$(curl -s $REPO_URL/raw/$REPO_BRANCH/version)
    
    if [[ "$VERSION" < "$latest_ver" ]]; then
        echo -e "${YELLOW}New version $latest_ver is available${NC}"
        echo -e "Current version: $VERSION"
        read -p "Would you like to update? [y/n]: " do_update
        
        if [[ $do_update =~ ^[Yy]$ ]]; then
            # Download latest version
            wget -q $REPO_URL/archive/refs/heads/$REPO_BRANCH.zip
            unzip -q $REPO_BRANCH.zip
            cd faiz-vpn-$REPO_BRANCH
            
            # Re-run installation
            bash install.sh --update
            exit 0
        fi
    else
        echo -e "${GREEN}You have the latest version${NC}"
    fi
}

# Add backup function
backup_configs() {
    echo -e "Backing up existing configurations..."
    BACKUP_DIR="/root/vpn-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p $BACKUP_DIR
    
    # Backup existing configs
    if [ -d "$SCRIPT_DIR" ]; then
        cp -r $SCRIPT_DIR $BACKUP_DIR/
    fi
    if [ -d "$CONFIG_DIR" ]; then
        cp -r $CONFIG_DIR $BACKUP_DIR/
    fi
    if [ -d "$BOT_DIR" ]; then
        cp -r $BOT_DIR $BACKUP_DIR/
    fi
    
    # Backup service configs
    if [ -f "/etc/squid/squid.conf" ]; then
        cp /etc/squid/squid.conf $BACKUP_DIR/
    fi
    if [ -f "/etc/stunnel/stunnel.conf" ]; then
        cp /etc/stunnel/stunnel.conf $BACKUP_DIR/
    fi
    
    echo -e "${GREEN}Configurations backed up to: $BACKUP_DIR${NC}"
}

# Add uninstall function
uninstall() {
    echo -e "${RED}Warning: This will remove all VPN script configurations${NC}"
    read -p "Are you sure you want to uninstall? [y/N]: " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo -e "Uninstalling..."
        
        # Stop services
        systemctl stop ws-proxy python-proxy squid stunnel4
        systemctl disable ws-proxy python-proxy squid stunnel4
        
        # Remove directories
        rm -rf $SCRIPT_DIR $CONFIG_DIR $BOT_DIR
        
        # Remove symlinks
        rm -f /usr/local/bin/{menu,menu-ssh,menu-xray,menu-argo,menu-security,menu-settings,menu-backup,menu-bot}
        
        # Restore original configs
        if [ -f "/etc/squid/squid.conf.bak" ]; then
            mv /etc/squid/squid.conf.bak /etc/squid/squid.conf
        fi
        if [ -f "/etc/stunnel/stunnel.conf.bak" ]; then
            mv /etc/stunnel/stunnel.conf.bak /etc/stunnel/stunnel.conf
        fi
        
        echo -e "${GREEN}Uninstallation completed${NC}"
        exit 0
    fi
}

# Main installation
echo -e "Starting installation..."

# Check root
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Modify main execution
case $MODE in
    install)
        backup_configs
        create_directories
        install_dependencies
        copy_scripts
        set_permissions
        create_symlinks
        configure_services
        ;;
    update)
        backup_configs
        copy_scripts
        set_permissions
        ;;
    uninstall)
        uninstall
        ;;
esac

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