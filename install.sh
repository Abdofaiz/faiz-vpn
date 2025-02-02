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
wget -O add-ssh https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/add-ssh
wget -O trial-ssh https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/trial-ssh
wget -O renew-ssh https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/renew-ssh
wget -O del-ssh https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/del-ssh
wget -O cek-ssh https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/cek-ssh
wget -O member-ssh https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/member-ssh
wget -O del-expired https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/del-expired
wget -O autokill-ssh https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/autokill-ssh
wget -O port-ssh https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/port-ssh
wget -O limit-ssh https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/limit-ssh

# Create main menu script
cat > /root/faiz-vpn/menu/menu <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}         MAIN MENU          ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e ""
echo -e "${GREEN}XRAY MENU${NC}"
echo -e " 1) Vmess Menu"
echo -e " 2) Vless Menu"
echo -e " 3) Trojan Menu"
echo -e ""
echo -e "${GREEN}SSH MENU${NC}"
echo -e " 4) SSH Menu"
echo -e ""
echo -e "${GREEN}SYSTEM MENU${NC}"
echo -e " 5) Running Services"
echo -e " 6) RAM Usage"
echo -e " 7) System Version"
echo -e " 8) Domain Settings"
echo -e " 9) Login Monitor"
echo -e ""
echo -e "${GREEN}MANAGEMENT MENU${NC}"
echo -e "10) Change Port"
echo -e "11) Backup Data"
echo -e "12) Restore Data"
echo -e "13) Webmin Panel"
echo -e "14) Speedtest"
echo -e "15) Auto Reboot"
echo -e ""
echo -e "${GREEN}ADDITIONAL MENU${NC}"
echo -e "16) Update Script"
echo -e "17) Install BBR"
echo -e "18) Clear Log"
echo -e "19) Clear Cache"
echo -e "20) Auto Kill Multi Login"
echo -e " 0) Exit"
echo -e ""
echo -e "${BLUE}=============================${NC}"
read -p "Select menu : " menu_num

case \$menu_num in
    1) vmess-menu ;;
    2) vless-menu ;;
    3) trojan-menu ;;
    4) ssh-menu ;;
    5) running ;;
    6) ram ;;
    7) version ;;
    8) domain ;;
    9) login ;;
    10) port-menu ;;
    11) backup ;;
    12) restore ;;
    13) webmin ;;
    14) speedtest ;;
    15) auto-reboot ;;
    16) update ;;
    17) bbr ;;
    18) clear-log ;;
    19) clear-cache ;;
    20) auto-kill ;;
    0) exit 0 ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
EOF

# Create VMESS menu
cat > /root/faiz-vpn/menu/vmess-menu <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}         VMESS MENU         ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e ""
echo -e " 1) Create Account"
echo -e " 2) Trial Account"
echo -e " 3) Extend Account"
echo -e " 4) Delete Account"
echo -e " 5) Check User Login"
echo -e " 6) Check Config"
echo -e " 0) Back to Main Menu"
echo -e ""
echo -e "${BLUE}=============================${NC}"
read -p "Select menu : " num

case \$num in
    1) add-vmess ;;
    2) trial-vmess ;;
    3) renew-vmess ;;
    4) del-vmess ;;
    5) cek-vmess ;;
    6) config-vmess ;;
    0) menu ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
EOF

# Create VLESS menu
cat > /root/faiz-vpn/menu/vless-menu <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}         VLESS MENU         ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e ""
echo -e " 1) Create Account"
echo -e " 2) Trial Account"
echo -e " 3) Extend Account"
echo -e " 4) Delete Account"
echo -e " 5) Check User Login"
echo -e " 6) Check Config"
echo -e " 0) Back to Main Menu"
echo -e ""
echo -e "${BLUE}=============================${NC}"
read -p "Select menu : " num

case \$num in
    1) add-vless ;;
    2) trial-vless ;;
    3) renew-vless ;;
    4) del-vless ;;
    5) cek-vless ;;
    6) config-vless ;;
    0) menu ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
EOF

# Create TROJAN menu
cat > /root/faiz-vpn/menu/trojan-menu <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}        TROJAN MENU         ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e ""
echo -e " 1) Create Account"
echo -e " 2) Trial Account"
echo -e " 3) Extend Account"
echo -e " 4) Delete Account"
echo -e " 5) Check User Login"
echo -e " 6) Check Config"
echo -e " 0) Back to Main Menu"
echo -e ""
echo -e "${BLUE}=============================${NC}"
read -p "Select menu : " num

case \$num in
    1) add-trojan ;;
    2) trial-trojan ;;
    3) renew-trojan ;;
    4) del-trojan ;;
    5) cek-trojan ;;
    6) config-trojan ;;
    0) menu ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
EOF

# Create SSH menu
cat > /root/faiz-vpn/menu/ssh-menu <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}         SSH MENU           ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e ""
echo -e " 1) Create SSH Account"
echo -e " 2) Trial SSH Account"
echo -e " 3) Extend SSH Account"
echo -e " 4) Delete SSH Account"
echo -e " 5) Check SSH User Login"
echo -e " 6) List SSH Members"
echo -e " 7) Delete Expired Users"
echo -e " 8) Set Auto Kill"
echo -e " 9) Check SSH Port"
echo -e "10) Set Multi Login Limit"
echo -e " 0) Back to Main Menu"
echo -e ""
echo -e "${BLUE}=============================${NC}"
read -p "Select menu : " num

case \$num in
    1) add-ssh ;;
    2) trial-ssh ;;
    3) renew-ssh ;;
    4) del-ssh ;;
    5) cek-ssh ;;
    6) member-ssh ;;
    7) del-expired ;;
    8) autokill-ssh ;;
    9) port-ssh ;;
    10) limit-ssh ;;
    0) menu ;;
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