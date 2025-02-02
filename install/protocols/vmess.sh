#!/bin/bash

# Configure VMESS
cat > /etc/xray/vmess.json << EOF
{
    "inbounds": [
        {
            "port": 31296,
            "protocol": "vmess",
            "settings": {
                "clients": []
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                    "path": "/vmess"
                }
            }
        }
    ]
}
EOF 