#!/bin/bash
# XRAY Setup Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Generate UUIDs
UUID=$(cat /proc/sys/kernel/random/uuid)
UUID2=$(cat /proc/sys/kernel/random/uuid)
UUID3=$(cat /proc/sys/kernel/random/uuid)

# Create XRAY config directory
mkdir -p /usr/local/etc/xray
mkdir -p /var/log/xray

# Generate SSL Certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /usr/local/etc/xray/xray.key \
    -out /usr/local/etc/xray/xray.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Configure XRAY
cat > /usr/local/etc/xray/config.json <<EOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 8443,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${UUID}",
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/usr/local/etc/xray/xray.crt",
              "keyFile": "/usr/local/etc/xray/xray.key"
            }
          ]
        },
        "wsSettings": {
          "path": "/vmess"
        }
      }
    },
    {
      "port": 2053,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${UUID}"
          }
        ]
      },
      "streamSettings": {
        "network": "grpc",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/usr/local/etc/xray/xray.crt",
              "keyFile": "/usr/local/etc/xray/xray.key"
            }
          ]
        },
        "grpcSettings": {
          "serviceName": "vmess-grpc"
        }
      }
    },
    {
      "port": 8880,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${UUID2}",
            "flow": "xtls-rprx-direct"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/vless"
        }
      }
    },
    {
      "port": 2083,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${UUID2}"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "grpc",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/usr/local/etc/xray/xray.crt",
              "keyFile": "/usr/local/etc/xray/xray.key"
            }
          ]
        },
        "grpcSettings": {
          "serviceName": "vless-grpc"
        }
      }
    },
    {
      "port": 2087,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "${UUID3}"
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/usr/local/etc/xray/xray.crt",
              "keyFile": "/usr/local/etc/xray/xray.key"
            }
          ]
        },
        "wsSettings": {
          "path": "/trojan"
        }
      }
    },
    {
      "port": 2096,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "${UUID3}"
          }
        ]
      },
      "streamSettings": {
        "network": "grpc",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/usr/local/etc/xray/xray.crt",
              "keyFile": "/usr/local/etc/xray/xray.key"
            }
          ]
        },
        "grpcSettings": {
          "serviceName": "trojan-grpc"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF

# Set permissions
chown -R nobody.nogroup /var/log/xray
chmod -R 755 /var/log/xray

# Create client config info file
cat > /usr/local/etc/xray/client-info.txt <<EOF
VMESS WS TLS Configuration:
Address: $(curl -s ifconfig.me)
Port: 8443
UUID: ${UUID}
Path: /vmess
Network: ws
TLS: true

VMESS gRPC Configuration:
Address: $(curl -s ifconfig.me)
Port: 2053
UUID: ${UUID}
ServiceName: vmess-grpc
Network: grpc
TLS: true

VLESS WS Configuration:
Address: $(curl -s ifconfig.me)
Port: 8880
UUID: ${UUID2}
Path: /vless
Network: ws
TLS: false

VLESS gRPC Configuration:
Address: $(curl -s ifconfig.me)
Port: 2083
UUID: ${UUID2}
ServiceName: vless-grpc
Network: grpc
TLS: true

TROJAN WS Configuration:
Address: $(curl -s ifconfig.me)
Port: 2087
Password: ${UUID3}
Path: /trojan
Network: ws
TLS: true

TROJAN gRPC Configuration:
Address: $(curl -s ifconfig.me)
Port: 2096
Password: ${UUID3}
ServiceName: trojan-grpc
Network: grpc
TLS: true
EOF

# Enable and start XRAY
systemctl enable xray
systemctl restart xray

echo -e "${GREEN}XRAY setup completed!${NC}"
echo -e "${GREEN}Client configuration saved in /usr/local/etc/xray/client-info.txt${NC}" 