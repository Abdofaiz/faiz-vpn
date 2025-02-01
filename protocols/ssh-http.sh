#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SQUID_CONF="/etc/squid/squid.conf"
PROXY_PORT="80"
SSH_PORT="22"

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}            ${CYAN}HTTP PAYLOAD SETUP${NC}                    ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Configure Squid Proxy
setup_squid() {
    # Backup existing config
    cp $SQUID_CONF "${SQUID_CONF}.bak"
    
    # Write new config
    cat > $SQUID_CONF << EOF
http_port $PROXY_PORT
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
http_access allow all
forwarded_for off
via off
request_header_access X-Forwarded-For deny all
request_header_access Via deny all
request_header_access Cache-Control deny all
EOF

    # Restart Squid
    systemctl restart squid
}

# Configure SSH Payload
setup_payload() {
    read -p "Enter your payload host (e.g., example.com): " host
    
    # Create payload file
    cat > /etc/payload.txt << EOF
CONNECT [host_port] [protocol][crlf]Host: $host[crlf]X-Online-Host: $host[crlf]X-Forward-Host: $host[crlf]Connection: Keep-Alive[crlf][crlf]
EOF
    
    echo -e "${GREEN}Payload configuration saved${NC}"
}

# Main Setup
echo -e "Setting up HTTP Payload configuration..."
echo -e ""

# Setup Squid Proxy
echo -e "1) Configuring Squid Proxy..."
setup_squid
echo -e "${GREEN}✓ Squid Proxy configured on port $PROXY_PORT${NC}"

# Setup Payload
echo -e "\n2) Configuring Payload..."
setup_payload
echo -e "${GREEN}✓ Payload configuration complete${NC}"

# Show Configuration
echo -e "\n${CYAN}Configuration Summary:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Proxy Port    : ${GREEN}$PROXY_PORT${NC}"
echo -e "SSH Port      : ${GREEN}$SSH_PORT${NC}"
echo -e "Payload File  : ${GREEN}/etc/payload.txt${NC}"
echo -e "Squid Config  : ${GREEN}$SQUID_CONF${NC}"

echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-ssh 