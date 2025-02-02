#!/bin/bash
# Trojan GO Setup Script

# Download and install Trojan GO
latest_version=$(curl -s "https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
wget https://github.com/p4gefau1t/trojan-go/releases/download/${latest_version}/trojan-go-linux-amd64.zip
unzip trojan-go-linux-amd64.zip -d /usr/local/bin/
chmod +x /usr/local/bin/trojan-go

# Create config directory
mkdir -p /usr/local/etc/trojan-go

# Generate certificate if not exists
if [ ! -f "/usr/local/etc/xray/xray.crt" ]; then
    mkdir -p /usr/local/etc/xray
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /usr/local/etc/xray/xray.key \
        -out /usr/local/etc/xray/xray.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
fi

# Configure Trojan GO
cat > /usr/local/etc/trojan-go/config.json <<EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 2087,
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "password": [
        "$(cat /proc/sys/kernel/random/uuid)"
    ],
    "ssl": {
        "cert": "/usr/local/etc/xray/xray.crt",
        "key": "/usr/local/etc/xray/xray.key",
        "sni": "localhost"
    },
    "router": {
        "enabled": true,
        "block": [
            "geoip:private"
        ],
        "geoip": "/usr/local/share/trojan-go/geoip.dat",
        "geosite": "/usr/local/share/trojan-go/geosite.dat"
    },
    "websocket": {
        "enabled": true,
        "path": "/trojango",
        "host": "localhost"
    }
}
EOF

# Create systemd service
cat > /etc/systemd/system/trojan-go.service <<EOF
[Unit]
Description=Trojan-Go - An unidentifiable mechanism that helps you bypass GFW
Documentation=https://p4gefau1t.github.io/trojan-go/
After=network.target nss-lookup.target

[Service]
User=nobody
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/trojan-go -config /usr/local/etc/trojan-go/config.json
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Trojan GO service
systemctl enable trojan-go
systemctl start trojan-go 