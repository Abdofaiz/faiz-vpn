#!/bin/bash
# OpenVPN Setup Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Create directories
mkdir -p /etc/openvpn/server
mkdir -p /etc/openvpn/client
cd /etc/openvpn/server

# Generate static key for TLS
openvpn --genkey --secret ta.key

# Generate CA and Server certificates
cat > /etc/openvpn/server/vars <<EOF
set_var EASYRSA_REQ_COUNTRY    "US"
set_var EASYRSA_REQ_PROVINCE   "State"
set_var EASYRSA_REQ_CITY       "City"
set_var EASYRSA_REQ_ORG        "Organization"
set_var EASYRSA_REQ_EMAIL      "admin@example.com"
set_var EASYRSA_REQ_OU         "Community"
EOF

# Initialize PKI and build CA
easyrsa init-pki
easyrsa build-ca nopass
easyrsa gen-dh
easyrsa build-server-full server nopass
easyrsa gen-crl

# TCP Server Configuration
cat > /etc/openvpn/server/server-tcp.conf <<EOF
port 1194
proto tcp
dev tun
ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/server.crt
key /etc/openvpn/server/server.key
dh /etc/openvpn/server/dh.pem
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
duplicate-cn
cipher AES-256-CBC
tls-auth ta.key 0
keepalive 10 120
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
log /var/log/openvpn/openvpn.log
verb 3
EOF

# UDP Server Configuration
cat > /etc/openvpn/server/server-udp.conf <<EOF
port 2200
proto udp
dev tun
ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/server.crt
key /etc/openvpn/server/server.key
dh /etc/openvpn/server/dh.pem
server 10.9.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
duplicate-cn
cipher AES-256-CBC
tls-auth ta.key 0
keepalive 10 120
persist-key
persist-tun
status /var/log/openvpn/openvpn-udp-status.log
log /var/log/openvpn/openvpn-udp.log
verb 3
EOF

# SSL Configuration for WebSocket
cat > /etc/openvpn/server/server-ws.conf <<EOF
port 2086
proto tcp
dev tun
ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/server.crt
key /etc/openvpn/server/server.key
dh /etc/openvpn/server/dh.pem
server 10.10.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
duplicate-cn
cipher AES-256-CBC
tls-auth ta.key 0
keepalive 10 120
persist-key
persist-tun
status /var/log/openvpn/openvpn-ws-status.log
log /var/log/openvpn/openvpn-ws.log
verb 3
EOF

# Create client config templates
cat > /etc/openvpn/client/client-tcp.ovpn <<EOF
client
dev tun
proto tcp
remote SERVER_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
key-direction 1
verb 3
EOF

cat > /etc/openvpn/client/client-udp.ovpn <<EOF
client
dev tun
proto udp
remote SERVER_IP 2200
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
key-direction 1
verb 3
EOF

cat > /etc/openvpn/client/client-ws.ovpn <<EOF
client
dev tun
proto tcp
remote SERVER_IP 2086
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
key-direction 1
verb 3
http-proxy SERVER_IP 8080
http-proxy-option CUSTOM-HEADER Host ws.example.com
EOF

# Enable IP forwarding
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

# Configure firewall
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.10.0.0/24 -o eth0 -j MASQUERADE

# Save iptables rules
iptables-save > /etc/iptables/rules.v4

# Create systemd services
cat > /etc/systemd/system/openvpn-tcp.service <<EOF
[Unit]
Description=OpenVPN TCP Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/sbin/openvpn --config /etc/openvpn/server/server-tcp.conf
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/openvpn-udp.service <<EOF
[Unit]
Description=OpenVPN UDP Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/sbin/openvpn --config /etc/openvpn/server/server-udp.conf
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/openvpn-ws.service <<EOF
[Unit]
Description=OpenVPN WebSocket Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/sbin/openvpn --config /etc/openvpn/server/server-ws.conf
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable and start services
systemctl enable openvpn-tcp
systemctl enable openvpn-udp
systemctl enable openvpn-ws
systemctl start openvpn-tcp
systemctl start openvpn-udp
systemctl start openvpn-ws

echo -e "${GREEN}OpenVPN setup completed!${NC}"
echo -e "TCP Server running on port 1194"
echo -e "UDP Server running on port 2200"
echo -e "WebSocket Server running on port 2086" 