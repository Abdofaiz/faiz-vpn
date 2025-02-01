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
echo -e " ${RED}0)${NC} Exit"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-4]: "
read opt

case $opt in
    1) exec menu-ssh ;;
    2) exec menu-xray ;;
    3) exec menu-bot ;;
    4) exec menu-backup ;;
    0) exit ;;
    *) exec menu ;;
esac
EOL

# Make scripts executable
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

# Verify symlinks
for cmd in menu menu-ssh menu-xray menu-bot menu-backup; do
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