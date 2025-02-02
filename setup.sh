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
rm -f /usr/local/bin/{menu,ssh,xray,domain,backup,settings,port,firewall}

# Copy all menu scripts
cat > /usr/local/bin/domain << 'EOF'
#!/bin/bash
# Domain Settings Script
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Domain configuration file
DOMAIN_FILE="/root/domain"

add_domain() {
    read -p "Enter domain: " domain
    echo "$domain" > $DOMAIN_FILE
    
    # Update Nginx config
    cat > /etc/nginx/conf.d/xray.conf << EOF2
server {
    listen 80;
    server_name $domain;
    root /var/www/html;
    
    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF2
    
    systemctl restart nginx
    echo -e "${GREEN}Domain $domain has been set!${NC}"
}

renew_cert() {
    domain=$(cat $DOMAIN_FILE)
    echo -e "${YELLOW}Renewing SSL for $domain...${NC}"
    certbot --nginx -d $domain --non-interactive --agree-tos --email admin@$domain
    echo -e "${GREEN}SSL Certificate renewed!${NC}"
}

while true; do
    clear
    echo -e "${BLUE}=============================${NC}"
    echo -e "${YELLOW}    DOMAIN SETTINGS    ${NC}"
    echo -e "${BLUE}=============================${NC}"
    echo -e ""
    echo -e "${GREEN}1${NC}. Add/Change Domain"
    echo -e "${GREEN}2${NC}. Renew SSL Certificate"
    echo -e "${GREEN}3${NC}. Show Current Domain"
    echo -e "${GREEN}0${NC}. Back to Main Menu"
    echo -e ""
    read -p "Select option: " choice
    case $choice in
        1) add_domain ;;
        2) renew_cert ;;
        3) 
            if [ -f "$DOMAIN_FILE" ]; then
                echo -e "Current domain: ${GREEN}$(cat $DOMAIN_FILE)${NC}"
            else
                echo -e "${RED}No domain set${NC}"
            fi
            ;;
        0) break ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -n 1 -s -r -p "Press any key to continue"
done
EOF

cat > /usr/local/bin/backup << 'EOF'
#!/bin/bash
# Backup Settings Script
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BACKUP_DIR="/root/backup"

create_backup() {
    mkdir -p $BACKUP_DIR
    DATE=$(date +%Y-%m-%d)
    echo -e "${YELLOW}Creating backup...${NC}"
    
    # Backup important directories
    tar -czf $BACKUP_DIR/backup-$DATE.tar.gz \
        /etc/xray \
        /usr/local/etc/xray \
        /etc/nginx/conf.d \
        /root/domain \
        /root/autoscript
        
    echo -e "${GREEN}Backup created: ${NC}backup-$DATE.tar.gz"
}

restore_backup() {
    echo -e "${YELLOW}Available backups:${NC}"
    ls -1 $BACKUP_DIR/*.tar.gz 2>/dev/null
    echo ""
    read -p "Enter backup file name: " file
    
    if [ -f "$BACKUP_DIR/$file" ]; then
        echo -e "${YELLOW}Restoring backup...${NC}"
        tar -xzf "$BACKUP_DIR/$file" -C /
        systemctl restart nginx xray
        echo -e "${GREEN}Backup restored successfully!${NC}"
    else
        echo -e "${RED}Backup file not found${NC}"
    fi
}

while true; do
    clear
    echo -e "${BLUE}=============================${NC}"
    echo -e "${YELLOW}    BACKUP SETTINGS    ${NC}"
    echo -e "${BLUE}=============================${NC}"
    echo -e ""
    echo -e "${GREEN}1${NC}. Create Backup"
    echo -e "${GREEN}2${NC}. Restore Backup"
    echo -e "${GREEN}3${NC}. List Backups"
    echo -e "${GREEN}0${NC}. Back to Main Menu"
    echo -e ""
    read -p "Select option: " choice
    case $choice in
        1) create_backup ;;
        2) restore_backup ;;
        3) 
            echo -e "${YELLOW}Available backups:${NC}"
            ls -1 $BACKUP_DIR/*.tar.gz 2>/dev/null || echo -e "${RED}No backups found${NC}"
            ;;
        0) break ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -n 1 -s -r -p "Press any key to continue"
done
EOF

cat > /usr/local/bin/settings << 'EOF'
#!/bin/bash
# System Settings Script
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

while true; do
    clear
    echo -e "${BLUE}=============================${NC}"
    echo -e "${YELLOW}    SYSTEM SETTINGS    ${NC}"
    echo -e "${BLUE}=============================${NC}"
    echo -e ""
    echo -e "${GREEN}1${NC}. Change Timezone"
    echo -e "${GREEN}2${NC}. Change Password"
    echo -e "${GREEN}3${NC}. Update System"
    echo -e "${GREEN}4${NC}. Install BBR"
    echo -e "${GREEN}5${NC}. Speedtest"
    echo -e "${GREEN}0${NC}. Back to Main Menu"
    echo -e ""
    read -p "Select option: " choice
    case $choice in
        1) 
            dpkg-reconfigure tzdata
            ;;
        2) 
            passwd
            ;;
        3)
            apt update && apt upgrade -y
            echo -e "${GREEN}System updated successfully!${NC}"
            ;;
        4)
            echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
            echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
            sysctl -p
            echo -e "${GREEN}BBR installed successfully!${NC}"
            ;;
        5)
            speedtest-cli
            ;;
        0) break ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -n 1 -s -r -p "Press any key to continue"
done
EOF

cat > /usr/local/bin/port << 'EOF'
#!/bin/bash
# Port Settings Script
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

change_port() {
    service=$1
    current_port=$2
    
    read -p "Enter new port for $service: " new_port
    case $service in
        "SSH")
            sed -i "s/Port $current_port/Port $new_port/" /etc/ssh/sshd_config
            systemctl restart ssh
            ;;
        "XRAY")
            sed -i "s/\"port\": $current_port/\"port\": $new_port/" /usr/local/etc/xray/config.json
            systemctl restart xray
            ;;
        "Dropbear")
            sed -i "s/DROPBEAR_PORT=$current_port/DROPBEAR_PORT=$new_port/" /etc/default/dropbear
            systemctl restart dropbear
            ;;
    esac
    echo -e "${GREEN}$service port changed to $new_port${NC}"
}

while true; do
    clear
    echo -e "${BLUE}=============================${NC}"
    echo -e "${YELLOW}    PORT SETTINGS    ${NC}"
    echo -e "${BLUE}=============================${NC}"
    echo -e ""
    echo -e "${GREEN}1${NC}. Change SSH Port (Current: $(grep "Port " /etc/ssh/sshd_config | cut -d' ' -f2))"
    echo -e "${GREEN}2${NC}. Change XRAY Port (Current: $(grep -o '"port": [0-9]*' /usr/local/etc/xray/config.json | cut -d' ' -f2))"
    echo -e "${GREEN}3${NC}. Change Dropbear Port (Current: $(grep "DROPBEAR_PORT=" /etc/default/dropbear | cut -d'=' -f2))"
    echo -e "${GREEN}0${NC}. Back to Main Menu"
    echo -e ""
    read -p "Select option: " choice
    case $choice in
        1) change_port "SSH" "$(grep "Port " /etc/ssh/sshd_config | cut -d' ' -f2)" ;;
        2) change_port "XRAY" "$(grep -o '"port": [0-9]*' /usr/local/etc/xray/config.json | cut -d' ' -f2)" ;;
        3) change_port "Dropbear" "$(grep "DROPBEAR_PORT=" /etc/default/dropbear | cut -d'=' -f2)" ;;
        0) break ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -n 1 -s -r -p "Press any key to continue"
done
EOF

cat > /usr/local/bin/firewall << 'EOF'
#!/bin/bash
# Firewall Settings Script
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

while true; do
    clear
    echo -e "${BLUE}=============================${NC}"
    echo -e "${YELLOW}    FIREWALL SETTINGS    ${NC}"
    echo -e "${BLUE}=============================${NC}"
    echo -e ""
    echo -e "${GREEN}1${NC}. View Firewall Status"
    echo -e "${GREEN}2${NC}. Enable Firewall"
    echo -e "${GREEN}3${NC}. Disable Firewall"
    echo -e "${GREEN}4${NC}. Add Port"
    echo -e "${GREEN}5${NC}. Remove Port"
    echo -e "${GREEN}0${NC}. Back to Main Menu"
    echo -e ""
    read -p "Select option: " choice
    case $choice in
        1) ufw status ;;
        2) ufw enable ;;
        3) ufw disable ;;
        4)
            read -p "Enter port to allow: " port
            ufw allow $port
            echo -e "${GREEN}Port $port has been allowed${NC}"
            ;;
        5)
            read -p "Enter port to remove: " port
            ufw delete allow $port
            echo -e "${GREEN}Port $port has been removed${NC}"
            ;;
        0) break ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -n 1 -s -r -p "Press any key to continue"
done
EOF

# Make all scripts executable
chmod +x /usr/local/bin/{menu,ssh,xray,domain,backup,settings,port,firewall}

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