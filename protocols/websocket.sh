#!/bin/bash

# Install WebSocket dependencies
print_info "Installing WebSocket..."
apt install -y python3 python3-pip
pip3 install websockets

# Create WebSocket service for HTTP
cat > /etc/systemd/system/ws-http.service << EOF
[Unit]
Description=WebSocket HTTP Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/bin/ws-http.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ws-http
systemctl start ws-http
print_success "WebSocket installed and configured" 