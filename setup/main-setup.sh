#!/bin/bash
# Comprehensive VPS Setup Script

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

# System Configuration
echo -e "${BLUE}Configuring system...${NC}"

# Set timezone
timedatectl set-timezone Asia/Jakarta

# Install essential packages
apt install -y \
    jq \
    curl \
    socat \
    netcat \
    python3 \
    python3-pip \
    vnstat \
    fail2ban \
    iptables \
    iptables-persistent \
    net-tools \
    cron \
    rsyslog

# Security configurations
echo -e "${BLUE}Setting up security...${NC}"

# Configure fail2ban
cat > /etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF

systemctl restart fail2ban

# Basic firewall rules
iptables -F
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 8069 -j ACCEPT
iptables -A INPUT -j DROP

# Save iptables rules
netfilter-persistent save

# Setup cron jobs
echo -e "${BLUE}Setting up cron jobs...${NC}"
cat > /etc/cron.d/autoscript <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Auto backup
0 0 * * * root /usr/local/bin/auto-backup
# Clear expired users
0 * * * * root /usr/local/bin/delete-expired
# Monitor resources
*/5 * * * * root /usr/local/bin/monitor-resources
EOF

# Create log directory
mkdir -p /var/log/autoscript
touch /var/log/autoscript/access.log

# Install Base Packages
apt install -y \
    openssh-server \
    dropbear \
    stunnel4 \
    squid \
    openvpn \
    xl2tpd \
    badvpn \
    nginx \
    python3 \
    python3-pip \
    bzip2 \
    gzip \
    coreutils \
    screen \
    curl \
    unzip \
    wget \
    git \
    build-essential \
    golang

# Create directories
mkdir -p /etc/xray
mkdir -p /usr/local/etc/xray
mkdir -p /var/log/xray
mkdir -p /var/log/nginx
mkdir -p /var/log/openvpn
mkdir -p /etc/slowdns

# Install XRAY Core
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Setup Components:

# 1. SSH & Dropbear
echo -e "${BLUE}Setting up SSH and Dropbear...${NC}"
source /root/autoscript/ssh/ssh-setup.sh

# 2. WebSocket
echo -e "${BLUE}Setting up WebSocket...${NC}"
source /root/autoscript/websocket/ws-setup.sh

# 3. XRAY (VMESS, VLESS, TROJAN)
echo -e "${BLUE}Setting up XRAY...${NC}"
source /root/autoscript/xray/xray-setup.sh

# 4. OpenVPN (TCP, UDP, WS)
echo -e "${BLUE}Setting up OpenVPN...${NC}"
source /root/autoscript/openvpn/openvpn-setup.sh

# 5. L2TP/IPSec
echo -e "${BLUE}Setting up L2TP...${NC}"
source /root/autoscript/l2tp/l2tp-setup.sh

# 6. SlowDNS
echo -e "${BLUE}Setting up SlowDNS...${NC}"
source /root/autoscript/slowdns/slowdns-setup.sh

# 7. UDPGW
echo -e "${BLUE}Setting up UDPGW...${NC}"
source /root/autoscript/udpgw/udpgw-setup.sh

# Create menu script
cat > /usr/local/bin/menu <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=== VPS Management Menu ===${NC}"
echo -e "1) User Management"
echo -e "2) Show Service Status"
echo -e "3) Show Port Status"
echo -e "4) Show System Information"
echo -e "5) Restart All Services"
echo -e "0) Exit"
read -p "Select option: " choice

case \$choice in
    1) source /usr/local/bin/user-management.sh ;;
    2) 
        echo -e "\n${YELLOW}Service Status:${NC}"
        systemctl status ssh | grep Active
        systemctl status dropbear | grep Active
        systemctl status stunnel4 | grep Active
        systemctl status openvpn* | grep Active
        systemctl status xray | grep Active
        systemctl status xl2tpd | grep Active
        systemctl status slowdns-server | grep Active
        systemctl status badvpn-udpgw | grep Active
        ;;
    3)
        echo -e "\n${YELLOW}Port Status:${NC}"
        netstat -tulpn | grep LISTEN
        ;;
    4)
        echo -e "\n${YELLOW}System Information:${NC}"
        uptime -p
        free -h
        df -h
        ;;
    5)
        echo -e "\n${YELLOW}Restarting all services...${NC}"
        systemctl restart ssh
        systemctl restart dropbear
        systemctl restart stunnel4
        systemctl restart openvpn*
        systemctl restart xray
        systemctl restart xl2tpd
        systemctl restart slowdns-server
        systemctl restart badvpn-udpgw
        echo -e "${GREEN}All services restarted${NC}"
        ;;
    0) exit 0 ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
EOF

chmod +x /usr/local/bin/menu

echo -e "${GREEN}Installation completed!${NC}"
echo -e "Use 'menu' command to access the management menu" 