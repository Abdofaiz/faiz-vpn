#!/bin/bash
# Test Installation Script

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

clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}    TESTING INSTALLATION     ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e ""

# Create required directories
echo -e "Creating directories..."
mkdir -p /etc/xray
mkdir -p /var/log/xray
mkdir -p /root/faiz-vpn/menu

# Download menu scripts from GitHub
echo -e "Downloading menu scripts..."
cd /root/faiz-vpn/menu
wget -O add-trojan https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/add-trojan
wget -O add-vless https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/add-vless
wget -O add-vmess https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/add-vmess
wget -O cek-trojan https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/cek-trojan
wget -O cek-vless https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/cek-vless
wget -O cek-vmess https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/cek-vmess
wget -O del-trojan https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/del-trojan
wget -O del-vless https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/del-vless
wget -O del-vmess https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/del-vmess
wget -O renew-trojan https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/renew-trojan
wget -O renew-vless https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/renew-vless
wget -O renew-vmess https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/renew-vmess
wget -O trial-trojan https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/trial-trojan
wget -O trial-vless https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/trial-vless
wget -O trial-vmess https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/trial-vmess
wget -O running https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/running
wget -O ram https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/ram
wget -O version https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/version
wget -O domain https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/domain
wget -O login https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/login

# Create main menu script
cat > /root/faiz-vpn/menu/menu <<EOF
#!/bin/bash
# Main Menu Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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
    1) /root/faiz-vpn/menu/user-menu ;;
    2) /root/faiz-vpn/menu/cert-menu ;;
    3) /root/faiz-vpn/menu/bandwidth ;;
    4) /root/faiz-vpn/menu/log ;;
    5) /root/faiz-vpn/menu/limit ;;
    6) /root/faiz-vpn/menu/port ;;
    7) /root/faiz-vpn/menu/domain ;;
    8) /root/faiz-vpn/menu/ws ;;
    9) /root/faiz-vpn/menu/xray ;;
    10) /root/faiz-vpn/menu/ssh ;;
    0) exit 0 ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
EOF

# Create dummy config files
echo -e "Creating test config files..."
echo "domain.com" > /etc/xray/domain
echo "1.0.0" > /root/faiz-vpn/version

# Create dummy XRAY config
cat > /etc/xray/config.json <<EOF
{
    "inbounds": [],
    "outbounds": [],
    "routing": {},
    "policy": {}
}
EOF

# Create dummy log file
touch /var/log/xray/access.log

# Create dummy log-install.txt
cat > /root/log-install.txt <<EOF
Vmess TLS         : 443
Vmess None TLS    : 80
Vless TLS         : 443
Vless None TLS    : 80
Trojan WS TLS     : 443
EOF

# Make all menu scripts executable
echo -e "Setting permissions..."
chmod +x /root/faiz-vpn/menu/*

# Make menu script executable
chmod +x /root/faiz-vpn/menu/menu

# Create symlink to menu
ln -sf /root/faiz-vpn/menu/menu /usr/local/bin/menu

echo -e ""
echo -e "${GREEN}Test installation completed!${NC}"
echo -e "Use ${YELLOW}menu${NC} command to access the management menu"
echo -e "${BLUE}=============================${NC}"