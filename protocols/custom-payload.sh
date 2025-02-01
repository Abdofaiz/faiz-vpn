#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
PAYLOAD_DIR="/etc/vpn/payloads"
PROXY_CONF="/etc/vpn/proxy.conf"

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}          ${CYAN}CUSTOM PAYLOAD CONFIGURATION${NC}             ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Create directories
mkdir -p $PAYLOAD_DIR

# Payload Templates
PAYLOAD_TEMPLATES=(
    "CONNECT [host_port] [protocol][crlf]Host: [host][crlf]X-Online-Host: [host][crlf]Connection: Keep-Alive[crlf][crlf]"
    "GET http://[host]/ HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf][crlf]"
    "CONNECT [host_port] HTTP/1.0[crlf]Host: [host][crlf]X-Forward-Host: [host][crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][crlf]"
    "PUT [host_port] HTTP/1.1[crlf]Host: [host][crlf]X-Online-Host: [host][crlf]X-Forward-Host: [host][crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][crlf]"
)

# Proxy Configuration
setup_proxy() {
    echo -e "\n${CYAN}Proxy Configuration${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "1) Squid Proxy"
    echo -e "2) Python Proxy"
    echo -e "3) Custom Proxy"
    echo -ne "\nSelect proxy type [1-3]: "
    read proxy_type
    
    case $proxy_type in
        1)
            read -p "Enter Squid port [80]: " squid_port
            squid_port=${squid_port:-80}
            setup_squid_proxy $squid_port
            ;;
        2)
            read -p "Enter Python proxy port [8080]: " python_port
            python_port=${python_port:-8080}
            setup_python_proxy $python_port
            ;;
        3)
            read -p "Enter custom proxy command: " custom_proxy
            echo "$custom_proxy" > $PROXY_CONF
            ;;
    esac
}

# Create Custom Payload
create_payload() {
    echo -e "\n${CYAN}Payload Creation${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "1) Use Template"
    echo -e "2) Create Custom"
    echo -ne "\nSelect option [1-2]: "
    read payload_opt
    
    case $payload_opt in
        1)
            echo -e "\nAvailable Templates:"
            for i in "${!PAYLOAD_TEMPLATES[@]}"; do
                echo -e "$((i+1))) ${PAYLOAD_TEMPLATES[$i]}"
            done
            
            read -p "Select template number: " template_num
            template=${PAYLOAD_TEMPLATES[$((template_num-1))]}
            
            read -p "Enter host: " host
            read -p "Enter port: " port
            
            # Replace variables in template
            payload=${template//\[host\]/$host}
            payload=${payload//\[host_port\]/$host:$port}
            payload=${payload//\[protocol\]/HTTP/1.1}
            payload=${payload//\[ua\]/Mozilla\/5.0}
            
            echo "$payload" > "$PAYLOAD_DIR/payload_${host}_${port}.txt"
            ;;
        2)
            read -p "Enter payload name: " payload_name
            echo "Enter payload content (Ctrl+D when done):"
            cat > "$PAYLOAD_DIR/$payload_name.txt"
            ;;
    esac
}

# Add proxy setup functions
setup_squid_proxy() {
    local port=$1
    apt-get update
    apt-get install -y squid || return 1
    
    # Backup and configure squid
    cp /etc/squid/squid.conf /etc/squid/squid.conf.bak
    cat > /etc/squid/squid.conf << EOF
http_port $port
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
http_access allow all
request_header_access X-Forwarded-For deny all
request_header_access Via deny all
request_header_access Cache-Control deny all
forwarded_for off
via off
EOF
    
    systemctl restart squid
    echo -e "${GREEN}Squid proxy configured on port $port${NC}"
}

setup_python_proxy() {
    local port=$1
    apt-get update
    apt-get install -y python3 python3-pip || return 1
    pip3 install proxy.py || return 1
    
    # Create and start Python proxy service
    cat > /etc/systemd/system/python-proxy.service << EOF
[Unit]
Description=Python Proxy Server
After=network.target

[Service]
ExecStart=/usr/local/bin/proxy --port $port
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable python-proxy
    systemctl restart python-proxy
    echo -e "${GREEN}Python proxy configured on port $port${NC}"
}

# Add payload testing function
test_payload() {
    local payload_file=$1
    local host=$(grep -oP 'Host: \K[^ ]+' "$payload_file")
    local port=$(grep -oP '\[host_port\] \K[0-9]+' "$payload_file" || echo "80")
    
    echo -e "Testing connection to $host:$port..."
    if nc -zv $host $port 2>/dev/null; then
        echo -e "${GREEN}Connection successful${NC}"
        echo -e "Testing payload..."
        cat "$payload_file" | nc $host $port
        echo -e "${GREEN}Payload sent${NC}"
    else
        echo -e "${RED}Connection failed${NC}"
    fi
}

# Main Menu
while true; do
    echo -e "\n${CYAN}Main Menu${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "1) Configure Proxy"
    echo -e "2) Create Payload"
    echo -e "3) List Payloads"
    echo -e "4) Test Payload"
    echo -e "5) Delete Payload"
    echo -e "0) Back to SSH Menu"
    echo -ne "\nSelect an option [0-5]: "
    read opt

    case $opt in
        1) setup_proxy ;;
        2) create_payload ;;
        3)
            echo -e "\n${CYAN}Available Payloads:${NC}"
            ls -1 $PAYLOAD_DIR
            ;;
        4)
            echo -e "\n${CYAN}Testing Payload...${NC}"
            read -p "Enter payload file to test: " test_payload
            if [ -f "$PAYLOAD_DIR/$test_payload" ]; then
                echo -e "\n${GREEN}Testing connection...${NC}"
                test_payload $PAYLOAD_DIR/$test_payload
            else
                echo -e "${RED}Payload file not found${NC}"
            fi
            ;;
        5)
            echo -e "\n${CYAN}Available Payloads:${NC}"
            ls -1 $PAYLOAD_DIR
            read -p "Enter payload to delete: " del_payload
            rm -f "$PAYLOAD_DIR/$del_payload"
            echo -e "${GREEN}Payload deleted${NC}"
            ;;
        0) 
            menu-ssh
            break
            ;;
    esac
done 