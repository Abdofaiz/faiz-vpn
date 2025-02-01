#!/bin/bash

# Install XRAY
print_info "Installing XRAY..."

# Download XRAY installer
curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh | bash -s -- install

# Configure XRAY for port 443 (TLS)
cat > /usr/local/etc/xray/config.json << EOF
{
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$(cat /proc/sys/kernel/random/uuid)",
            "flow": "xtls-rprx-direct"
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 22,
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
              "certificateFile": "/path/to/cert.crt",
              "keyFile": "/path/to/private.key"
            }
          ]
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

systemctl enable xray
systemctl restart xray
print_success "XRAY installed and configured" 