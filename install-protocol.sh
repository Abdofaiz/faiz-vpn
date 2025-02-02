#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
NC='\033[0m'

# Paths
XRAY_CONFIG="/etc/xray/config.json"
DOMAIN_FILE="/etc/xray/domain"

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}            ${CYAN}PROTOCOL INSTALLER${NC}                    ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Install required packages
install_packages() {
    apt update
    apt install -y curl wget socat ufw nginx certbot python3-certbot-nginx uuid-runtime

    # Install XRAY
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

    # Install Stunnel & Dropbear
    apt install -y stunnel4 dropbear
}

# Setup domain and SSL
setup_domain() {
    read -p "Enter your domain: " domain
    echo "$domain" > $DOMAIN_FILE

    # Get SSL certificate
    certbot --nginx -d $domain --non-interactive --agree-tos --email admin@$domain
    
    # Copy certificates for XRAY
    cp /etc/letsencrypt/live/$domain/fullchain.pem /etc/xray/xray.crt
    cp /etc/letsencrypt/live/$domain/privkey.pem /etc/xray/xray.key
}

# Configure XRAY
setup_xray() {
    local domain=$(cat $DOMAIN_FILE)
    
    # Create base config
    cat > $XRAY_CONFIG << EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 80,
            "xver": 1
          },
          {
            "path": "/vmess",
            "dest": 31296,
            "xver": 1
          },
          {
            "path": "/vless",
            "dest": 31297,
            "xver": 1
          },
          {
            "path": "/trojan",
            "dest": 31298,
            "xver": 1
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "xtls",
        "xtlsSettings": {
          "alpn": ["http/1.1"],
          "certificates": [
            {
              "certificateFile": "/etc/xray/xray.crt",
              "keyFile": "/etc/xray/xray.key"
            }
          ]
        }
      }
    },
    {
      "port": 31296,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/vmess"
        }
      }
    },
    {
      "port": 31297,
      "protocol": "vless",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/vless"
        }
      }
    },
    {
      "port": 31298,
      "protocol": "trojan",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/trojan"
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
}

# Configure SSH
setup_ssh() {
    # Configure Dropbear
    sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
    sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=80/g' /etc/default/dropbear
    
    # Configure Stunnel
    cat > /etc/stunnel/stunnel.conf << EOF
pid = /var/run/stunnel.pid
cert = /etc/xray/xray.crt
key = /etc/xray/xray.key
client = no
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 443
connect = 127.0.0.1:80
EOF

    # Enable services
    systemctl enable dropbear
    systemctl enable stunnel4
}

# Main installation
echo -e "${CYAN}Installing required packages...${NC}"
install_packages

echo -e "${CYAN}Setting up domain and SSL...${NC}"
setup_domain

echo -e "${CYAN}Configuring XRAY...${NC}"
setup_xray

echo -e "${CYAN}Configuring SSH...${NC}"
setup_ssh

# Restart services
systemctl restart nginx
systemctl restart xray
systemctl restart dropbear
systemctl restart stunnel4

echo -e "${GREEN}Installation completed!${NC}"
echo -e "Your server now supports:"
echo -e "1. VMESS WS TLS/Non-TLS"
echo -e "2. VLESS WS TLS/Non-TLS"
echo -e "3. VLESS XTLS"
echo -e "4. TROJAN WS/TCP"
echo -e "5. SSH WS TLS/Non-TLS"
echo -e "6. SSH SSL/TLS" 