#!/bin/bash
# UDPGW Setup Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Install Build Dependencies
apt install -y cmake build-essential git

# Download and Build badvpn-udpgw
cd /tmp
git clone https://github.com/ambrop72/badvpn.git
cd badvpn
mkdir build
cd build
cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
make install

# Create systemd service
cat > /etc/systemd/system/badvpn-udpgw.service <<EOF
[Unit]
Description=BadVPN UDP Gateway
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 100
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl enable badvpn-udpgw
systemctl start badvpn-udpgw

echo -e "${GREEN}UDPGW setup completed!${NC}" 