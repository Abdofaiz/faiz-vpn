#!/bin/bash
# OHP Setup Script

# Download and install OHP
wget https://github.com/lfasmpao/open-http-puncher/releases/download/0.1/ohpserver-linux32.zip
unzip ohpserver-linux32.zip
mv ohpserver /usr/local/bin/
chmod +x /usr/local/bin/ohpserver

# Create OHP SSH Service
cat > /etc/systemd/system/ohp-ssh.service <<EOF
[Unit]
Description=OHP SSH
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ohpserver -port 8181 -proxy 127.0.0.1:22 -tunnel 127.0.0.1:443
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Create OHP Dropbear Service
cat > /etc/systemd/system/ohp-dropbear.service <<EOF
[Unit]
Description=OHP Dropbear
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ohpserver -port 8282 -proxy 127.0.0.1:143 -tunnel 127.0.0.1:443
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Create OHP OpenVPN Service
cat > /etc/systemd/system/ohp-openvpn.service <<EOF
[Unit]
Description=OHP OpenVPN
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ohpserver -port 8383 -proxy 127.0.0.1:1194 -tunnel 127.0.0.1:443
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable and start OHP services
systemctl enable ohp-ssh
systemctl enable ohp-dropbear
systemctl enable ohp-openvpn
systemctl start ohp-ssh
systemctl start ohp-dropbear
systemctl start ohp-openvpn 