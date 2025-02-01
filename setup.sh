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

# Required files check
declare -A REQUIRED_FILES=(
    ["menu.sh"]="Main Menu"
    ["menu/menu-ssh.sh"]="SSH Menu"
    ["menu/menu-xray.sh"]="Xray Menu"
    ["menu/menu-bot.sh"]="Bot Menu"
    ["protocols/ssh.sh"]="SSH Protocol"
    ["protocols/websocket.sh"]="WebSocket Protocol"
    ["protocols/xray.sh"]="Xray Protocol"
    ["bot/register-ip.sh"]="IP Registration"
    ["bot/ip-lookup.sh"]="IP Lookup"
)

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

# Set permissions function
set_script_permissions() {
    local dir=$1
    echo -e "Setting permissions for $dir..."
    find "$dir" -type f -name "*.sh" -exec chmod +x {} \;
    find "$dir" -type f -name "menu*" -exec chmod +x {} \;
}

# Download function
download_script() {
    local file="$1"
    local dest="$2"
    echo -e "Downloading $file..."
    mkdir -p "$(dirname "$dest")"
    
    wget -q "$REPO_RAW/$file" -O "$dest"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to download $file${NC}"
        # Create basic script if it's a required file
        if [[ "${REQUIRED_FILES[$file]}" ]]; then
            echo -e "${YELLOW}Creating basic ${REQUIRED_FILES[$file]} script...${NC}"
            create_basic_script "$file" "$dest"
        fi
        return 1
    fi
    
    chmod 755 "$dest"
    if [ ! -x "$dest" ]; then
        echo -e "${RED}Failed to set permissions for $dest${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Downloaded $file${NC}"
}

# Create basic script function
create_basic_script() {
    local file="$1"
    local dest="$2"
    
    case "$file" in
        "menu.sh")
            cat > "$dest" << 'EOF'
#!/bin/bash
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}                ${CYAN}MAIN MENU${NC}                         ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e " ${GREEN}1)${NC} SSH Menu"
echo -e " ${GREEN}2)${NC} Xray Menu"
echo -e " ${GREEN}3)${NC} Bot Menu"
echo -e " ${RED}0)${NC} Exit"
echo -e ""
read -p "Select option [0-3]: " opt

case $opt in
    1) menu-ssh ;;
    2) menu-xray ;;
    3) menu-bot ;;
    0) exit ;;
    *) menu ;;
esac
EOF
            ;;
        "menu/menu-ssh.sh")
            cat > "$dest" << 'EOF'
#!/bin/bash
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}              ${CYAN}SSH VPN MANAGER${NC}                     ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Menu Options
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Direct SSH (Default Port)"
echo -e " ${GREEN}2)${NC} HTTP Payload (Port 80)"
echo -e " ${GREEN}3)${NC} SSL/TLS Payload (Port 443)"
echo -e " ${GREEN}4)${NC} Websocket HTTP (Port 80)"
echo -e " ${GREEN}5)${NC} Websocket SSL/TLS (Port 443)"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
read -p "Select an option [0-5]: " opt

case $opt in
    1) /usr/local/vpn-script/protocols/ssh.sh ;;
    2) /usr/local/vpn-script/protocols/websocket.sh ;;
    3) /usr/local/vpn-script/protocols/xray.sh ;;
    0) menu ;;
    *) menu-ssh ;;
esac
EOF
            ;;
        "menu/menu-xray.sh")
            cat > "$dest" << 'EOF'
#!/bin/bash
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}              ${CYAN}XRAY MANAGER${NC}                        ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "Coming Soon..."
echo -e ""
read -n 1 -s -r -p "Press any key to return to menu"
menu
EOF
            ;;
        "menu/menu-bot.sh")
            cat > "$dest" << 'EOF'
#!/bin/bash
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script paths
BOT_DIR="/usr/local/vpn-script/bot"

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}               ${CYAN}BOT MENU${NC}                           ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Menu Options
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Register IP"
echo -e " ${GREEN}2)${NC} IP Lookup"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
read -p "Select an option [0-2]: " opt

case $opt in
    1) $BOT_DIR/register-ip.sh ;;
    2) $BOT_DIR/ip-lookup.sh ;;
    0) menu ;;
    *) menu-bot ;;
esac
EOF
            ;;
        "protocols/ssh.sh"|"protocols/websocket.sh"|"protocols/xray.sh")
            cat > "$dest" << 'EOF'
#!/bin/bash
echo "Protocol script - Coming Soon"
read -n 1 -s -r -p "Press any key to return to menu"
menu-ssh
EOF
            ;;
        "bot/register-ip.sh"|"bot/ip-lookup.sh")
            cat > "$dest" << 'EOF'
#!/bin/bash
echo "Bot function - Coming Soon"
read -n 1 -s -r -p "Press any key to return to menu"
menu-bot
EOF
            ;;
    esac
    
    chmod 755 "$dest"
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
    # Set permissions for both source and destination
    chmod 755 "$src"
    chmod 755 "$dest"
}

# Download main scripts
download_script "menu.sh" "$SCRIPT_DIR/menu.sh"

# Download menu scripts
for script in menu-ssh.sh menu-xray.sh menu-bot.sh; do
    download_script "menu/$script" "$MENU_DIR/$script"
done

# Download protocol scripts
for script in ssh.sh websocket.sh xray.sh; do
    download_script "protocols/$script" "$PROTO_DIR/$script"
done

# Download bot scripts
for script in register-ip.sh ip-lookup.sh; do
    download_script "bot/$script" "$BOT_DIR/$script"
done

# Download config files
download_script "squid.conf" "/etc/squid/squid.conf"

# After downloading all scripts
echo -e "Setting permissions..."
set_script_permissions "$SCRIPT_DIR"
set_script_permissions "/usr/local/bin"

# Create symlinks
echo -e "Creating symlinks..."
mkdir -p /usr/local/bin
chmod 755 /usr/local/bin

create_symlink "$SCRIPT_DIR/menu.sh" "/usr/local/bin/menu"
create_symlink "$MENU_DIR/menu-ssh.sh" "/usr/local/bin/menu-ssh"
create_symlink "$MENU_DIR/menu-xray.sh" "/usr/local/bin/menu-xray"
create_symlink "$MENU_DIR/menu-bot.sh" "/usr/local/bin/menu-bot"

# Verify permissions
echo -e "Verifying permissions..."
for cmd in menu menu-ssh menu-xray menu-bot; do
    if [ ! -x "/usr/local/bin/$cmd" ]; then
        echo -e "${RED}Warning: $cmd is not executable${NC}"
        chmod 755 "/usr/local/bin/$cmd"
    fi
done

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