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

# Create menu scripts
echo -e "${CYAN}Creating menu scripts...${NC}"

# Create SSH menu
cat > "$MENU_DIR/menu-ssh.sh" << 'EOL'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script paths
PROTO_DIR="/usr/local/vpn-script/protocols"

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}              ${CYAN}SSH VPN MANAGER${NC}                     ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
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
    1) exec bash "$PROTO_DIR/ssh.sh" create ;;
    2) exec bash "$PROTO_DIR/ssh.sh" trial ;;
    3) exec bash "$PROTO_DIR/ssh.sh" renew ;;
    4) exec bash "$PROTO_DIR/ssh.sh" delete ;;
    5) exec bash "$PROTO_DIR/ssh.sh" check ;;
    6) exec bash "$PROTO_DIR/ssh.sh" list ;;
    7) exec bash "$PROTO_DIR/ssh.sh" expired ;;
    8) exec bash "$PROTO_DIR/ssh.sh" autokill ;;
    9) exec bash "$PROTO_DIR/ssh.sh" multi ;;
    10) exec bash "$PROTO_DIR/ssh.sh" restart ;;
    0) exec menu ;;
    *) exec menu-ssh ;;
esac
EOL

# Create XRAY menu
cat > "$MENU_DIR/menu-xray.sh" << 'EOL'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script paths
PROTO_DIR="/usr/local/vpn-script/protocols"

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}              ${CYAN}XRAY MANAGER${NC}                        ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Install XRAY"
echo -e " ${GREEN}2)${NC} VLESS Menu"
echo -e " ${GREEN}3)${NC} VMESS Menu"
echo -e " ${GREEN}4)${NC} Trojan Menu"
echo -e " ${GREEN}5)${NC} List All Members"
echo -e " ${GREEN}6)${NC} Check Running Services"
echo -e " ${GREEN}7)${NC} Update Certificate"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-7]: "
read opt

case $opt in
    1) exec bash "$PROTO_DIR/xray.sh" install ;;
    2) exec bash "$PROTO_DIR/xray.sh" vless-menu ;;
    3) exec bash "$PROTO_DIR/xray.sh" vmess-menu ;;
    4) exec bash "$PROTO_DIR/xray.sh" trojan-menu ;;
    5) exec bash "$PROTO_DIR/xray.sh" list-all ;;
    6) exec bash "$PROTO_DIR/xray.sh" status ;;
    7) exec bash "$PROTO_DIR/xray.sh" update-cert ;;
    0) exec menu ;;
    *) exec menu-xray ;;
esac
EOL

# Create Bot menu
cat > "$MENU_DIR/menu-bot.sh" << 'EOL'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script paths
BOT_DIR="/usr/local/vpn-script/bot"

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}              ${CYAN}BOT MANAGER${NC}                         ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Register IP"
echo -e " ${GREEN}2)${NC} IP Lookup"
echo -e " ${GREEN}3)${NC} Bot Settings"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-3]: "
read opt

case $opt in
    1) exec bash "$BOT_DIR/register-ip.sh" ;;
    2) exec bash "$BOT_DIR/ip-lookup.sh" ;;
    3) exec bash "$BOT_DIR/settings.sh" ;;
    0) exec menu ;;
    *) exec menu-bot ;;
esac
EOL

# Create Backup menu
cat > "$MENU_DIR/menu-backup.sh" << 'EOL'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}             ${CYAN}BACKUP MANAGER${NC}                       ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Backup VPN"
echo -e " ${GREEN}2)${NC} Restore VPN"
echo -e " ${GREEN}3)${NC} Auto Backup Settings"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-3]: "
read opt

case $opt in
    1) exec bash "$SCRIPT_DIR/backup.sh" backup ;;
    2) exec bash "$SCRIPT_DIR/backup.sh" restore ;;
    3) exec bash "$SCRIPT_DIR/backup.sh" settings ;;
    0) exec menu ;;
    *) exec menu-backup ;;
esac
EOL

# Create main menu
cat > "$SCRIPT_DIR/menu.sh" << 'EOL'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}               ${CYAN}MAIN MENU${NC}                          ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} SSH Menu"
echo -e " ${GREEN}2)${NC} XRAY Menu"
echo -e " ${GREEN}3)${NC} Bot Menu"
echo -e " ${GREEN}4)${NC} Backup Menu"
echo -e " ${GREEN}5)${NC} Settings Menu"
echo -e " ${RED}0)${NC} Exit"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-5]: "
read opt

case $opt in
    1) exec menu-ssh ;;
    2) exec menu-xray ;;
    3) exec menu-bot ;;
    4) exec menu-backup ;;
    5) exec menu-settings ;;
    0) exit ;;
    *) exec menu ;;
esac
EOL

# Create settings menu
cat > "$MENU_DIR/menu-settings.sh" << 'EOL'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}             ${CYAN}SETTINGS MANAGER${NC}                     ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Change Port Settings"
echo -e " ${GREEN}2)${NC} Change Domain"
echo -e " ${GREEN}3)${NC} Change Banner"
echo -e " ${GREEN}4)${NC} Restart All Services"
echo -e " ${GREEN}5)${NC} Check System Status"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-5]: "
read opt

case $opt in
    1) exec bash "$SCRIPT_DIR/settings.sh" port ;;
    2) exec bash "$SCRIPT_DIR/settings.sh" domain ;;
    3) exec bash "$SCRIPT_DIR/settings.sh" banner ;;
    4) exec bash "$SCRIPT_DIR/settings.sh" restart ;;
    5) exec bash "$SCRIPT_DIR/settings.sh" status ;;
    0) exec menu ;;
    *) exec menu-settings ;;
esac
EOL

# Make all menu scripts executable
chmod +x "$MENU_DIR"/*.sh
chmod +x "$SCRIPT_DIR/menu.sh"

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
ln -sf "$MENU_DIR/menu-backup.sh" "/usr/local/bin/menu-backup"
ln -sf "$MENU_DIR/menu-settings.sh" "/usr/local/bin/menu-settings"

# Verify symlinks
for cmd in menu menu-ssh menu-xray menu-bot menu-backup menu-settings; do
    if [ ! -L "/usr/local/bin/$cmd" ]; then
        echo -e "${RED}Failed to create symlink for $cmd${NC}"
    fi
done

# Create version file
echo "1.0.0" > /home/ver

# Install dependencies
echo -e "${CYAN}Installing dependencies...${NC}"
apt-get update
apt-get install -y python3 python3-pip netcat openssl stunnel4 squid curl wget jq

# Final setup
echo -e "\n${GREEN}Installation completed!${NC}"
echo -e "\nYou can now:"
echo -e "1. Run ${GREEN}menu${NC} to access the main menu"
echo -e "2. Configure your bot settings in ${GREEN}menu-bot${NC}"
echo -e "3. Set up your VPN configurations in ${GREEN}menu-ssh${NC} or ${GREEN}menu-xray${NC}"

# Run menu
echo -e ""
read -p "Would you like to run the menu now? [y/n]: " run_menu
if [[ $run_menu =~ ^[Yy]$ ]]; then
    exec menu
fi 