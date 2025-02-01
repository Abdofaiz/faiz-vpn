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

# Copy menu scripts
echo -e "${CYAN}Installing menu scripts...${NC}"
cat > "$SCRIPT_DIR/menu.sh" << 'EOL'
#!/bin/bash
# Menu script content here
...(paste the entire menu.sh content)...
EOL

# Create menu-ssh script
cat > "$MENU_DIR/menu-ssh.sh" << 'EOL'
#!/bin/bash
# SSH Menu content here
...(paste the entire menu-ssh.sh content)...
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
ln -sf "$SCRIPT_DIR/menu.sh" /usr/local/bin/menu
ln -sf "$MENU_DIR/menu-ssh.sh" /usr/local/bin/menu-ssh
ln -sf "$MENU_DIR/menu-xray.sh" /usr/local/bin/menu-xray
ln -sf "$MENU_DIR/menu-bot.sh" /usr/local/bin/menu-bot

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