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
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}         MAIN MENU          ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e ""
echo -e "${GREEN}VMESS MENU${NC}"
echo -e " 1) Add Vmess"
echo -e " 2) Delete Vmess"
echo -e " 3) Renew Vmess"
echo -e " 4) Check Vmess Login"
echo -e " 5) Trial Vmess"
echo -e ""
echo -e "${GREEN}VLESS MENU${NC}"
echo -e " 6) Add Vless"
echo -e " 7) Delete Vless"
echo -e " 8) Renew Vless"
echo -e " 9) Check Vless Login"
echo -e "10) Trial Vless"
echo -e ""
echo -e "${GREEN}TROJAN MENU${NC}"
echo -e "11) Add Trojan"
echo -e "12) Delete Trojan"
echo -e "13) Renew Trojan"
echo -e "14) Check Trojan Login"
echo -e "15) Trial Trojan"
echo -e ""
echo -e "${GREEN}SYSTEM MENU${NC}"
echo -e "16) Check Running Services"
echo -e "17) Check RAM Usage"
echo -e "18) Check Version"
echo -e "19) Check Domain"
echo -e "20) Check Login Sessions"
echo -e " 0) Exit"
echo -e ""
echo -e "${BLUE}=============================${NC}"
read -p "Select menu : " menu_num

case \$menu_num in
    1) add-vmess ;;
    2) del-vmess ;;
    3) renew-vmess ;;
    4) cek-vmess ;;
    5) trial-vmess ;;
    6) add-vless ;;
    7) del-vless ;;
    8) renew-vless ;;
    9) cek-vless ;;
    10) trial-vless ;;
    11) add-trojan ;;
    12) del-trojan ;;
    13) renew-trojan ;;
    14) cek-trojan ;;
    15) trial-trojan ;;
    16) running ;;
    17) ram ;;
    18) version ;;
    19) domain ;;
    20) login ;;
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

# Create menu command symlink
ln -sf /root/faiz-vpn/menu/menu /usr/local/bin/menu

echo -e ""
echo -e "${GREEN}Test installation completed!${NC}"
echo -e "Type ${YELLOW}menu${NC} to access the main menu"
echo -e "${BLUE}=============================${NC}"