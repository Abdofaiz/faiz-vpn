#!/bin/bash

setup_ssh() {
    # Configure Dropbear
    sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
    sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=80/g' /etc/default/dropbear
    
    # Configure Stunnel
    cat > /etc/stunnel/stunnel.conf << EOF
pid = /var/run/stunnel.pid
cert = /etc/xray/xray.crt
key = /etc/xray/xray.key
client = no
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 443
connect = 127.0.0.1:80
EOF

    # Enable services
    systemctl enable dropbear
    systemctl enable stunnel4
}

setup_ssh 