#!/bin/bash
# Main Installation Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check root
if [ "${EUID}" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# Create directories
mkdir -p /usr/local/bin
mkdir -p /etc/xray
mkdir -p /usr/local/etc/xray
mkdir -p /var/log/xray
mkdir -p /var/log/nginx
mkdir -p /etc/slowdns
mkdir -p /etc/autoscript

# Clone repository
echo -e "${BLUE}Downloading scripts...${NC}"
cd /tmp
rm -rf autoscript-main autoscript.zip
wget https://github.com/yourusername/autoscript/archive/refs/heads/main.zip -O autoscript.zip
unzip autoscript.zip
cd autoscript-main

# Copy files to system
cp -r menu/* /usr/local/bin/
cp -r setup/* /usr/local/etc/autoscript/
cp -r utils/* /usr/local/bin/

# Make scripts executable
chmod +x /usr/local/bin/*

# Create menu symlinks
ln -sf /usr/local/bin/user /usr/local/bin/menu-user
ln -sf /usr/local/bin/cert /usr/local/bin/menu-cert
ln -sf /usr/local/bin/bandwidth /usr/local/bin/menu-bandwidth
ln -sf /usr/local/bin/log /usr/local/bin/menu-log
ln -sf /usr/local/bin/limit /usr/local/bin/menu-limit
ln -sf /usr/local/bin/port /usr/local/bin/menu-port
ln -sf /usr/local/bin/domain /usr/local/bin/menu-domain
ln -sf /usr/local/bin/ws /usr/local/bin/menu-ws
ln -sf /usr/local/bin/xray /usr/local/bin/menu-xray
ln -sf /usr/local/bin/ssh /usr/local/bin/menu-ssh

# Create main menu
cat > /usr/local/bin/menu <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}     VPS MANAGER MENU     ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e ""
echo -e "${GREEN}1${NC}. User Management"
echo -e "${GREEN}2${NC}. Certificate Management"
echo -e "${GREEN}3${NC}. Bandwidth Monitor"
echo -e "${GREEN}4${NC}. Log Viewer"
echo -e "${GREEN}5${NC}. Limit Configuration"
echo -e "${GREEN}6${NC}. Port Management"
echo -e "${GREEN}7${NC}. Domain Settings"
echo -e "${GREEN}8${NC}. WebSocket Settings"
echo -e "${GREEN}9${NC}. XRAY Configuration"
echo -e "${GREEN}10${NC}. SSH Settings"
echo -e "${GREEN}0${NC}. Exit"
echo -e ""
echo -e "${BLUE}=============================${NC}"
read -p "Select menu: " menu_option

case \$menu_option in
    1) menu-user ;;
    2) menu-cert ;;
    3) menu-bandwidth ;;
    4) menu-log ;;
    5) menu-limit ;;
    6) menu-port ;;
    7) menu-domain ;;
    8) menu-ws ;;
    9) menu-xray ;;
    10) menu-ssh ;;
    0) exit 0 ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
EOF

chmod +x /usr/local/bin/menu

# Run setup scripts
echo -e "${BLUE}Running setup scripts...${NC}"
bash /root/autoscript/setup/main-setup.sh
bash /root/autoscript/ssh/ssh-setup.sh
bash /root/autoscript/websocket/ws-setup.sh
bash /root/autoscript/xray/xray-setup.sh
bash /root/autoscript/openvpn/openvpn-setup.sh
bash /root/autoscript/l2tp/l2tp-setup.sh
bash /root/autoscript/slowdns/slowdns-setup.sh
bash /root/autoscript/udpgw/udpgw-setup.sh
bash /root/autoscript/backup/backup-setup.sh
bash /root/autoscript/dropbear/dropbear-setup.sh

# Run tests
echo -e "${BLUE}Testing installation...${NC}"
bash /root/autoscript/test-install.sh

echo -e "${GREEN}Installation completed!${NC}"
echo -e "Use ${YELLOW}menu${NC} command to access the management menu" 