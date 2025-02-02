#!/bin/bash
# SlowDNS Setup Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Install required packages
apt install -y git golang dnsutils

# Create directories
mkdir -p /usr/local/slowdns
cd /usr/local/slowdns

# Download and build SlowDNS
git clone https://github.com/sygns13/slowdns.git
cd slowdns
go build

# Generate DNS key pair
echo -e "${GREEN}Generating DNS key pair...${NC}"
./slowdns keygen
mv server.key /root/server.key
mv server.pub /root/server.pub

# Get nameserver
NS_DOMAIN=$(cat /etc/resolv.conf | grep nameserver | head -n1 | awk '{print $2}')

# Create SlowDNS service for server
cat > /etc/systemd/system/slowdns-server.service <<EOF
[Unit]
Description=SlowDNS Server Service
After=network.target

[Service]
Type=simple
WorkingDirectory=/usr/local/slowdns/slowdns
ExecStart=/usr/local/slowdns/slowdns/slowdns server -dnsport=53 -udpport=5300 -keypath=/root/server.key
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Create client config generator
cat > /usr/local/bin/slowdns-config <<EOF
#!/bin/bash
if [ \$# -ne 1 ]; then
    echo "Usage: \$0 username"
    exit 1
fi

SERVER_IP=\$(curl -s ifconfig.me)
NS_DOMAIN=\$(cat /etc/resolv.conf | grep nameserver | head -n1 | awk '{print \$2}')
SERVER_PUB=\$(cat /root/server.pub)

cat << END
SlowDNS Client Configuration:
============================
Server IP: \$SERVER_IP
NS Domain: \$NS_DOMAIN
Public Key: \$SERVER_PUB
Username: \$1

Client Setup Instructions:
1. Install SlowDNS client
2. Save the public key as 'client.pub'
3. Run client with:
   ./slowdns client -udpport=5300 -dnsip=\$NS_DOMAIN -pubkey=client.pub -server=\$SERVER_IP

For Android:
1. Install SlowDNS app
2. Server: \$SERVER_IP
3. Public Key: \$SERVER_PUB
4. DNS Server: \$NS_DOMAIN
END
EOF

chmod +x /usr/local/bin/slowdns-config

# Configure iptables for SlowDNS
iptables -I INPUT -p udp --dport 53 -j ACCEPT
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300

# Save iptables rules
iptables-save > /etc/iptables/rules.v4

# Enable and start SlowDNS service
systemctl enable slowdns-server
systemctl start slowdns-server

echo -e "${GREEN}SlowDNS setup completed!${NC}"
echo -e "Server public key saved in /root/server.pub"
echo -e "Server private key saved in /root/server.key"
echo -e "Use 'slowdns-config username' to generate client configuration" 