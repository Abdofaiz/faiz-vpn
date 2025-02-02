#!/bin/bash
# Dropbear Setup Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Dropbear Configuration
echo -e "${GREEN}Configuring Dropbear...${NC}"
cat > /etc/default/dropbear <<EOF
NO_START=0
DROPBEAR_PORT=143
DROPBEAR_EXTRA_ARGS="-p 109"
DROPBEAR_BANNER="/etc/issue.net"
DROPBEAR_RECEIVE_WINDOW=65536
EOF

# Create SSL Certificate for Stunnel
echo -e "${GREEN}Creating SSL Certificate...${NC}"
mkdir -p /etc/stunnel
openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" \
    -keyout /etc/stunnel/stunnel.pem \
    -out /etc/stunnel/stunnel.pem

# Stunnel Configuration
echo -e "${GREEN}Configuring Stunnel...${NC}"
cat > /etc/stunnel/stunnel.conf <<EOF
pid = /var/run/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 445
connect = 127.0.0.1:109

[openssh]
accept = 777
connect = 127.0.0.1:22

[stunnel]
accept = 443
connect = 127.0.0.1:109
EOF

# Enable and Start Services
systemctl enable dropbear
systemctl enable stunnel4
systemctl restart dropbear
systemctl restart stunnel4

echo -e "${GREEN}Dropbear and Stunnel setup completed!${NC}" 