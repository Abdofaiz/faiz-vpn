#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Paths
SCRIPT_DIR="/usr/local/vpn-script"
MENU_DIR="$SCRIPT_DIR/menu"
PROTO_DIR="$SCRIPT_DIR/protocols"
BOT_DIR="$SCRIPT_DIR/bot"

# Create required directories
echo -e "${CYAN}Creating directories...${NC}"
mkdir -p "$SCRIPT_DIR"/{menu,protocols,bot} /etc/ssh /etc/xray /var/lib/crot /etc/vpn/{payloads,ssl} /etc/bot/{backups,.config}

# Create database files
touch /etc/ssh/.ssh.db /etc/xray/config.json /var/lib/crot/data-user-l2tp

# Install main menu
echo -e "${CYAN}Installing main menu...${NC}"
cat > "$SCRIPT_DIR/menu.sh" << 'EOL'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
NC='\033[0m'

# Paths
SCRIPT_DIR="/usr/local/vpn-script"
SSH_DB="/etc/ssh/.ssh.db"
XRAY_CONFIG="/etc/xray/config.json"
L2TP_DB="/var/lib/crot/data-user-l2tp"
VERSION_FILE="/home/ver"

# Get System Information
get_system_info() {
    source /etc/os-release
    ARCH=$(uname -m)
    KERNEL=$(uname -r)
    CPU_MODEL=$(grep -m 1 "model name" /proc/cpuinfo | cut -d ':' -f2 | sed 's/^ *//')
    CPU_CORES=$(grep -c "processor" /proc/cpuinfo)
    CPU_FREQ=$(grep -m 1 "cpu MHz" /proc/cpuinfo | cut -d ':' -f2 | sed 's/^ *//')
    
    TOTAL_RAM=$(free -m | awk 'NR==2 {printf "%.3f", $2/1024}')
    USED_RAM=$(free -m | awk 'NR==2 {printf "%.3f", $3/1024}')
    SWAP_TOTAL=$(free -m | awk 'NR==4 {print $2}')
    
    DISK_INFO=$(df -h / | awk 'NR==2 {print $2" (Used: "$3" Free: "$4")"}')
    
    DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "Not configured")
    IP=$(curl -s ipv4.icanhazip.com)
    ISP=$(curl -s ipinfo.io/org | tr -d '"')
    REGION=$(curl -s ipinfo.io/city),$(curl -s ipinfo.io/country)
    TIMEZONE=$(curl -s ipinfo.io/timezone)
    
    VERSION=$(cat $VERSION_FILE 2>/dev/null || echo "1.0.0")
}

# Get active users count
get_active_users() {
    SSH_USERS=$(grep -c "^###" $SSH_DB 2>/dev/null || echo "0")
    XRAY_USERS=$(grep -c "^###" $XRAY_CONFIG 2>/dev/null || echo "0")
    L2TP_USERS=$(grep -c "^###" $L2TP_DB 2>/dev/null || echo "0")
}

# Update system info
get_system_info
get_active_users

# Display Menu
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}               ${CYAN}SCRIPT BY USER_LEGEND${NC}               ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"

echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}                  ${CYAN}SYS INFO${NC}                         ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${GREEN}OS SYSTEM${NC}    : $ID $VERSION_ID"
echo -e "${GREEN}ARCH${NC}         : $ARCH"
echo -e "${GREEN}KERNEL TYPE${NC}  : $KERNEL"
echo -e "${GREEN}CPU MODEL${NC}    : $CPU_MODEL"
echo -e "${GREEN}NUMBER CORES${NC} : $CPU_CORES"
echo -e "${GREEN}CPU FREQ${NC}     : $CPU_FREQ MHz"
echo -e "${GREEN}TOTAL RAM${NC}    : $TOTAL_RAM GB / $USED_RAM GB Used"
echo -e "${GREEN}TOTAL SWAP${NC}   : $SWAP_TOTAL MB"
echo -e "${GREEN}TOTAL DISK${NC}   : $DISK_INFO"
echo -e "${GREEN}DOMAIN${NC}       : $DOMAIN"
echo -e "${GREEN}SLOWDNS${NC}      : dns.$DOMAIN"
echo -e "${GREEN}IP ADDRESS${NC}   : $IP"
echo -e "${GREEN}ISP${NC}          : $ISP"
echo -e "${GREEN}REGION${NC}       : $REGION [$TIMEZONE]"
echo -e "${GREEN}SCRIPT VER${NC}   : $VERSION"
echo -e ""

# Account Info
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "     ${CYAN}SSH & OVPN${NC} : $SSH_USERS ${GREEN}ACTIVE${NC}"
echo -e "     ${CYAN}XRAY${NC}       : $XRAY_USERS ${GREEN}ACTIVE${NC}"
echo -e "     ${CYAN}L2TP${NC}       : $L2TP_USERS ${GREEN}ACTIVE${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Main Menu
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}                ${CYAN}MAIN MENU${NC}                         ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Menu Options
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} MENU SSH & OVPN"
echo -e " ${GREEN}2)${NC} MENU XRAY"
echo -e " ${GREEN}3)${NC} MENU ARGO"
echo -e " ${GREEN}4)${NC} MENU SECURITY"
echo -e " ${GREEN}5)${NC} MENU SETTINGS"
echo -e " ${GREEN}6)${NC} BACKUP & RESTORE"
echo -e " ${GREEN}7)${NC} BOT FEATURES"
echo -e " ${RED}0)${NC} Exit"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-7]: "
read opt

case $opt in
    1) clear ; menu-ssh ;;
    2) clear ; menu-xray ;;
    3) clear ; menu-argo ;;
    4) clear ; menu-security ;;
    5) clear ; menu-settings ;;
    6) clear ; menu-backup ;;
    7) clear ; menu-bot ;;
    0) clear ; exit ;;
    *) clear ; menu ;;
esac
EOL

# Install SSH menu
echo -e "${CYAN}Installing SSH menu...${NC}"
cat > "$MENU_DIR/menu-ssh.sh" << 'EOL'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script paths
PROTO_DIR="/usr/local/vpn-script/protocols"

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}              ${CYAN}SSH VPN MANAGER${NC}                     ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Menu Options
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Create SSH Account"
echo -e " ${GREEN}2)${NC} Trial SSH Account"
echo -e " ${GREEN}3)${NC} Renew SSH Account"
echo -e " ${GREEN}4)${NC} Delete SSH Account"
echo -e " ${GREEN}5)${NC} Check User Login"
echo -e " ${GREEN}6)${NC} List Member SSH"
echo -e " ${GREEN}7)${NC} Delete User Expired"
echo -e " ${GREEN}8)${NC} Set up Autokill SSH"
echo -e " ${GREEN}9)${NC} Check User Multi Login"
echo -e " ${GREEN}10)${NC} Restart All Service"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-10]: "
read opt

case $opt in
    1) clear ; $PROTO_DIR/ssh.sh create ;;
    2) clear ; $PROTO_DIR/ssh.sh trial ;;
    3) clear ; $PROTO_DIR/ssh.sh renew ;;
    4) clear ; $PROTO_DIR/ssh.sh delete ;;
    5) clear ; $PROTO_DIR/ssh.sh check ;;
    6) clear ; $PROTO_DIR/ssh.sh list ;;
    7) clear ; $PROTO_DIR/ssh.sh expired ;;
    8) clear ; $PROTO_DIR/ssh.sh autokill ;;
    9) clear ; $PROTO_DIR/ssh.sh multi ;;
    10) clear ; $PROTO_DIR/ssh.sh restart ;;
    0) clear ; menu ;;
    *) clear ; menu-ssh ;;
esac
EOL

# Create menu-xray script
cat > "$MENU_DIR/menu-xray.sh" << 'EOL'
#!/bin/bash
# XRAY Menu content here
...(paste the entire menu-xray.sh content)...
EOL

# Create menu-bot script
cat > "$MENU_DIR/menu-bot.sh" << 'EOL'
#!/bin/bash
# Bot Menu content here
...(paste the entire menu-bot.sh content)...
EOL

# Create protocol scripts
echo -e "${CYAN}Installing protocol scripts...${NC}"
for proto in ssh websocket xray; do
    cat > "$PROTO_DIR/$proto.sh" << 'EOL'
#!/bin/bash
echo "Protocol $proto - Coming Soon"
read -n 1 -s -r -p "Press any key to return to menu"
menu-ssh
EOL
done

# Create bot scripts
echo -e "${CYAN}Installing bot scripts...${NC}"
for bot in register-ip ip-lookup; do
    cat > "$BOT_DIR/$bot.sh" << 'EOL'
#!/bin/bash
echo "Bot function $bot - Coming Soon"
read -n 1 -s -r -p "Press any key to return to menu"
menu-bot
EOL
done

# Set permissions
echo -e "${CYAN}Setting permissions...${NC}"
chmod +x "$SCRIPT_DIR/menu.sh"
chmod +x "$MENU_DIR"/*.sh
chmod +x "$PROTO_DIR"/*.sh
chmod +x "$BOT_DIR"/*.sh

# Create symlinks
echo -e "${CYAN}Creating symlinks...${NC}"
mkdir -p /usr/local/bin

# Remove old symlinks if they exist
rm -f /usr/local/bin/menu /usr/local/bin/menu-*

# Create new symlinks
ln -sf "$SCRIPT_DIR/menu.sh" "/usr/local/bin/menu"
ln -sf "$MENU_DIR/menu-ssh.sh" "/usr/local/bin/menu-ssh"
ln -sf "$MENU_DIR/menu-xray.sh" "/usr/local/bin/menu-xray"
ln -sf "$MENU_DIR/menu-bot.sh" "/usr/local/bin/menu-bot"

# Verify symlinks
for cmd in menu menu-ssh menu-xray menu-bot; do
    if [ ! -L "/usr/local/bin/$cmd" ]; then
        echo -e "${RED}Failed to create symlink for $cmd${NC}"
    fi
done

# Create version file
echo "1.0.0" > /home/ver

# Install dependencies
echo -e "${CYAN}Installing dependencies...${NC}"
apt-get update
apt-get install -y python3 python3-pip netcat openssl stunnel4 squid curl wget

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