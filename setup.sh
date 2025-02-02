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
mkdir -p /root/autoscript/{xray,nginx,menu}
mkdir -p /usr/local/etc/xray
mkdir -p /etc/nginx/conf.d

# Install XRAY
echo -e "\n${BLUE}[4/7]${NC} Installing XRAY..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Setup XRAY config
echo -e "\n${BLUE}[5/7]${NC} Setting up configurations..."
cat > /usr/local/etc/xray/config.json << EOF
{
    "inbounds": [
        {
            "port": 443,
            "protocol": "vless",
            "settings": {
                "clients": [],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "tls",
                "tlsSettings": {
                    "alpn": ["http/1.1"]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF

# Setup Nginx config
cat > /etc/nginx/conf.d/xray.conf << EOF
server {
    listen 80;
    server_name _;
    root /var/www/html;
    
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    location /xray {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:443;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
}
EOF

# Install menu scripts
echo -e "\n${BLUE}[6/7]${NC} Installing menu scripts..."
for script in menu ssh xray cert port domain backup ws; do
    wget -O /usr/local/bin/$script https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/$script
    chmod +x /usr/local/bin/$script
done

# Configure services
echo -e "\n${BLUE}[7/7]${NC} Configuring services..."
systemctl daemon-reload
systemctl enable nginx
systemctl enable xray
systemctl enable stunnel4
systemctl enable dropbear
systemctl enable fail2ban

# Start services
systemctl restart nginx
systemctl restart xray
systemctl restart stunnel4
systemctl restart dropbear
systemctl restart fail2ban

# Run installation test
echo -e "\n${YELLOW}Running installation test...${NC}"
bash /root/autoscript/test-install.sh

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}Installation completed successfully!${NC}"
    echo -e "\nYou can now use the following commands:"
    echo -e "${YELLOW}menu${NC} - Main menu"
    echo -e "${YELLOW}ssh${NC} - SSH manager"
    echo -e "${YELLOW}xray${NC} - XRAY manager"
    echo -e "${YELLOW}cert${NC} - Certificate manager"
    echo -e "\nDefault ports:"
    echo -e "SSH: 22"
    echo -e "XRAY: 443"
    echo -e "Nginx: 80"
else
    echo -e "\n${RED}Installation failed! Please check the errors above.${NC}"
fi 