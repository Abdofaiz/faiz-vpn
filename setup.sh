#!/bin/bash
# Automated VPN Installation Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check root
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi

clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}     VPN INSTALLATION     ${NC}"
echo -e "${BLUE}=============================${NC}"

# Update system
echo -e "\n${BLUE}[1/7]${NC} Updating system..."
apt update && apt upgrade -y
apt install -y wget curl jq unzip

# Install dependencies
echo -e "\n${BLUE}[2/7]${NC} Installing dependencies..."
apt install -y nginx python3 python3-pip stunnel4 dropbear fail2ban

# Create directory structure
echo -e "\n${BLUE}[3/7]${NC} Creating directory structure..."
mkdir -p /root/autoscript/{api,backup,boot,client,dropbear,l2tp,menu,ohp,openvpn,setup,slowdns,ssh,trojango,udpgw,utils,websocket,xray}
mkdir -p /usr/local/etc/xray
mkdir -p /etc/nginx/conf.d

# Install XRAY
echo -e "\n${BLUE}[4/7]${NC} Installing XRAY..."
systemctl stop xray >/dev/null 2>&1
rm -rf /usr/local/bin/xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Setup configurations
echo -e "\n${BLUE}[5/7]${NC} Setting up configurations..."
sleep 2

# Create menu scripts
echo -e "\n${BLUE}[6/7]${NC} Creating menu scripts..."

# Clean up existing menu files
rm -f /usr/local/bin/{menu,ssh,xray}

# Create SSH script
cat > /usr/local/bin/ssh << 'EOF'
#!/bin/bash
# SSH Manager Script
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

while true; do
    clear
    echo -e "${BLUE}=============================${NC}"
    echo -e "${YELLOW}     SSH MANAGER     ${NC}"
    echo -e "${BLUE}=============================${NC}"
    echo -e ""
    echo -e "${GREEN}1${NC}. Create Account"
    echo -e "${GREEN}2${NC}. Delete Account"
    echo -e "${GREEN}3${NC}. Extend Account"
    echo -e "${GREEN}4${NC}. List Accounts"
    echo -e "${GREEN}5${NC}. Monitor Users"
    echo -e "${GREEN}6${NC}. Lock/Unlock User"
    echo -e "${GREEN}0${NC}. Back to Main Menu"
    echo -e ""
    read -p "Select option: " choice
    case $choice in
        0) break ;;
        *) echo -e "${RED}Feature coming soon...${NC}" ;;
    esac
    read -n 1 -s -r -p "Press any key to continue"
done
EOF

# Create XRAY script
cat > /usr/local/bin/xray << 'EOF'
#!/bin/bash
# XRAY Manager Script
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

while true; do
    clear
    echo -e "${BLUE}=============================${NC}"
    echo -e "${YELLOW}     XRAY MANAGER     ${NC}"
    echo -e "${BLUE}=============================${NC}"
    echo -e ""
    echo -e "${GREEN}1${NC}. Create Account"
    echo -e "${GREEN}2${NC}. Delete Account"
    echo -e "${GREEN}3${NC}. Extend Account"
    echo -e "${GREEN}4${NC}. List Accounts"
    echo -e "${GREEN}5${NC}. Monitor Users"
    echo -e "${GREEN}6${NC}. Show Config"
    echo -e "${GREEN}0${NC}. Back to Main Menu"
    echo -e ""
    read -p "Select option: " choice
    case $choice in
        0) break ;;
        *) echo -e "${RED}Feature coming soon...${NC}" ;;
    esac
    read -n 1 -s -r -p "Press any key to continue"
done
EOF

# Create main menu script
cat > /usr/local/bin/menu << 'EOF'
#!/bin/bash
# Main Menu Script
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# System Information
clear_ram() {
    sync; echo 3 > /proc/sys/vm/drop_caches
    echo -e "${GREEN}RAM cleared successfully!${NC}"
}

show_system_info() {
    clear
    echo -e "${BLUE}=============================${NC}"
    echo -e "${YELLOW}     SYSTEM INFORMATION     ${NC}"
    echo -e "${BLUE}=============================${NC}"
    echo -e ""
    echo -e "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f2)"
    echo -e "Kernel: $(uname -r)"
    echo -e "Uptime: $(uptime -p)"
    echo -e "CPU Load: $(cat /proc/loadavg | awk '{print $1 ", " $2 ", " $3}')"
    echo -e "RAM Usage: $(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}')"
    echo -e "Disk Usage: $(df -h / | awk 'NR==2{print $5}')"
    echo -e ""
    read -n 1 -s -r -p "Press any key to continue"
}

show_running_services() {
    clear
    echo -e "${BLUE}=============================${NC}"
    echo -e "${YELLOW}     RUNNING SERVICES     ${NC}"
    echo -e "${BLUE}=============================${NC}"
    echo -e ""
    echo -e "NGINX: $(systemctl is-active nginx)"
    echo -e "XRAY: $(systemctl is-active xray)"
    echo -e "SSH: $(systemctl is-active ssh)"
    echo -e "Dropbear: $(systemctl is-active dropbear)"
    echo -e "Stunnel4: $(systemctl is-active stunnel4)"
    echo -e "Fail2Ban: $(systemctl is-active fail2ban)"
    echo -e ""
    read -n 1 -s -r -p "Press any key to continue"
}

while true; do
    clear
    echo -e "${BLUE}=============================${NC}"
    echo -e "${YELLOW}     MAIN MENU     ${NC}"
    echo -e "${BLUE}=============================${NC}"
    echo -e ""
    echo -e "${GREEN}1${NC}. SSH Menu"
    echo -e "${GREEN}2${NC}. XRAY Menu"
    echo -e "${GREEN}3${NC}. Domain Settings"
    echo -e "${GREEN}4${NC}. Backup Menu"
    echo -e "${GREEN}5${NC}. System Settings"
    echo -e ""
    echo -e "${BLUE}SYSTEM${NC}"
    echo -e "${GREEN}6${NC}. System Information"
    echo -e "${GREEN}7${NC}. Running Services"
    echo -e "${GREEN}8${NC}. Clear RAM Cache"
    echo -e "${GREEN}9${NC}. Reboot System"
    echo -e ""
    echo -e "${BLUE}SETTINGS${NC}"
    echo -e "${GREEN}10${NC}. Change Port"
    echo -e "${GREEN}11${NC}. Firewall Settings"
    echo -e "${GREEN}12${NC}. Update Script"
    echo -e ""
    echo -e "${GREEN}0${NC}. Exit"
    echo -e ""
    read -p "Select option: " choice
    case $choice in
        1) ssh ;;
        2) xray ;;
        3) domain ;;
        4) backup ;;
        5) settings ;;
        6) show_system_info ;;
        7) show_running_services ;;
        8) clear_ram ;;
        9) reboot ;;
        10) port ;;
        11) firewall ;;
        12) 
            echo -e "${YELLOW}Updating script...${NC}"
            wget -q -O /usr/local/bin/menu "https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/menu"
            chmod +x /usr/local/bin/menu
            echo -e "${GREEN}Script updated successfully!${NC}"
            sleep 2
            exec menu
            ;;
        0) break ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -n 1 -s -r -p "Press any key to continue"
done
EOF

# Make scripts executable
chmod +x /usr/local/bin/{menu,ssh,xray}

# Configure services
echo -e "\n${BLUE}[7/7]${NC} Configuring services..."
systemctl daemon-reload

# Enable services
systemctl enable nginx
systemctl enable xray
systemctl enable stunnel4
systemctl enable dropbear
systemctl enable fail2ban

# Start services
sleep 2
systemctl restart nginx
systemctl restart xray
systemctl restart stunnel4
systemctl restart dropbear
systemctl restart fail2ban

echo -e "\n${GREEN}Installation completed successfully!${NC}"
echo -e "\nYou can now use the following commands:"
echo -e "${YELLOW}menu${NC} - Main menu"
echo -e "${YELLOW}ssh${NC} - SSH manager"
echo -e "${YELLOW}xray${NC} - XRAY manager"
echo -e "\nDefault ports:"
echo -e "SSH: 22"
echo -e "XRAY: 443"
echo -e "Nginx: 80" 