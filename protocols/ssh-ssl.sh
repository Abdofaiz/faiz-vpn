#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SSL_PORT="443"
SSH_PORT="22"
STUNNEL_CONF="/etc/stunnel/stunnel.conf"

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}            ${CYAN}SSL/TLS PAYLOAD SETUP${NC}                 ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Configure Stunnel
setup_stunnel() {
    # Install stunnel if not present
    if ! command -v stunnel &> /dev/null; then
        apt-get update
        apt-get install -y stunnel4
    fi
    
    # Generate SSL certificate
    openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
        -subj "/C=US/ST=State/L=Location/O=Organization/CN=CommonName" \
        -keyout /etc/stunnel/stunnel.pem -out /etc/stunnel/stunnel.pem
    
    # Configure Stunnel
    cat > $STUNNEL_CONF << EOF
pid = /var/run/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[ssh]
accept = $SSL_PORT
connect = 127.0.0.1:$SSH_PORT
EOF

    # Enable and start Stunnel
    systemctl enable stunnel4
    systemctl restart stunnel4
}

# Configure SNI
setup_sni() {
    read -p "Enter SNI hostname (e.g., example.com): " sni_host
    
    # Add SNI configuration to stunnel
    sed -i "/\[ssh\]/a sni = $sni_host" $STUNNEL_CONF
    systemctl restart stunnel4
}

# Main Setup
echo -e "Setting up SSL/TLS Payload configuration..."
echo -e ""

# Setup Stunnel
echo -e "1) Configuring Stunnel..."
setup_stunnel
echo -e "${GREEN}✓ Stunnel configured on port $SSL_PORT${NC}"

# Setup SNI
echo -e "\n2) Configuring SNI..."
setup_sni
echo -e "${GREEN}✓ SNI configuration complete${NC}"

# Show Configuration
echo -e "\n${CYAN}Configuration Summary:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "SSL Port     : ${GREEN}$SSL_PORT${NC}"
echo -e "SSH Port     : ${GREEN}$SSH_PORT${NC}"
echo -e "Stunnel Conf : ${GREEN}$STUNNEL_CONF${NC}"
echo -e "Certificate  : ${GREEN}/etc/stunnel/stunnel.pem${NC}"

echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-ssh 