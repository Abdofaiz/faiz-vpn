#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
WS_PORT="80"
SSH_PORT="22"
PYTHON_PROXY="/usr/local/bin/ws-proxy"
SERVICE_FILE="/etc/systemd/system/ws-proxy.service"

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}         ${CYAN}WEBSOCKET HTTP PAYLOAD SETUP${NC}              ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Install Requirements
setup_requirements() {
    apt update
    apt install -y python3 python3-pip
    pip3 install websockets
}

# Create WebSocket Proxy Script
create_proxy_script() {
    cat > $PYTHON_PROXY << 'EOF'
#!/usr/bin/env python3
import asyncio
import websockets
import socket
import argparse
import ssl
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

SSH_PORT = $SSH_PORT

async def handle_connection(websocket, path):
    try:
        ssh_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        ssh_sock.connect(('127.0.0.1', SSH_PORT))
        
        async def forward_ws_to_ssh():
            try:
                while True:
                    data = await websocket.recv()
                    if not data:
                        break
                    ssh_sock.send(data)
            except:
                pass
                
        async def forward_ssh_to_ws():
            try:
                while True:
                    data = ssh_sock.recv(4096)
                    if not data:
                        break
                    await websocket.send(data)
            except:
                pass
                
        await asyncio.gather(
            forward_ws_to_ssh(),
            forward_ssh_to_ws()
        )
    except Exception as e:
        logger.error(f"Error: {e}")
    finally:
        ssh_sock.close()

async def main(host, port, ssl_cert=None):
    if ssl_cert:
        ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        ssl_context.load_cert_chain(ssl_cert)
    else:
        ssl_context = None
        
    async with websockets.serve(handle_connection, host, port, ssl=ssl_context):
        await asyncio.Future()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=80)
    parser.add_argument("--host", default="0.0.0.0")
    parser.add_argument("--cert", help="SSL certificate file")
    args = parser.parse_args()
    
    asyncio.run(main(args.host, args.port, args.cert))
EOF
    chmod +x $PYTHON_PROXY || cleanup
}

# Create Systemd Service
create_service() {
    cat > $SERVICE_FILE << EOF
[Unit]
Description=WebSocket SSH Proxy
After=network.target

[Service]
Type=simple
User=root
ExecStart=$PYTHON_PROXY --port $WS_PORT
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable ws-proxy
    systemctl restart ws-proxy
}

# Configure Custom Headers
setup_headers() {
    read -p "Enter custom header name (e.g., X-Custom-Header): " header_name
    read -p "Enter header value: " header_value
    
    # Add custom headers to proxy script
    sed -i "/async def handle_connection/a\    headers = {'$header_name': '$header_value'}" $PYTHON_PROXY
}

# Add after configuration section
check_existing() {
    if systemctl is-active --quiet ws-proxy; then
        echo -e "${YELLOW}WebSocket proxy service is already running${NC}"
        echo -e "Do you want to:"
        echo -e "1) Reconfigure"
        echo -e "2) Remove existing"
        echo -e "3) Exit"
        read -p "Select option: " existing_opt
        case $existing_opt in
            1) systemctl stop ws-proxy ;;
            2) 
                systemctl stop ws-proxy
                systemctl disable ws-proxy
                rm -f $PYTHON_PROXY $SERVICE_FILE
                ;;
            3) exit 1 ;;
        esac
    fi
}

# Add before main setup
cleanup() {
    systemctl stop ws-proxy 2>/dev/null
    rm -f $PYTHON_PROXY $SERVICE_FILE
    echo -e "${RED}Installation failed, cleaned up files${NC}"
    exit 1
}

# Main Setup
echo -e "Setting up WebSocket HTTP Payload..."
echo -e ""

# Install Requirements
echo -e "1) Installing requirements..."
setup_requirements
echo -e "${GREEN}✓ Requirements installed${NC}"

# Setup WebSocket Proxy
echo -e "\n2) Configuring WebSocket Proxy..."
create_proxy_script
create_service
echo -e "${GREEN}✓ WebSocket Proxy configured on port $WS_PORT${NC}"

# Setup Custom Headers
echo -e "\n3) Configure Custom Headers? [y/n]: "
read setup_custom
if [[ $setup_custom =~ ^[Yy]$ ]]; then
    setup_headers
    echo -e "${GREEN}✓ Custom headers configured${NC}"
fi

# Show Configuration
echo -e "\n${CYAN}Configuration Summary:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "WebSocket Port : ${GREEN}$WS_PORT${NC}"
echo -e "SSH Port       : ${GREEN}$SSH_PORT${NC}"
echo -e "Proxy Script   : ${GREEN}$PYTHON_PROXY${NC}"
echo -e "Service File   : ${GREEN}$SERVICE_FILE${NC}"

# Show connection example
echo -e "\n${CYAN}Connection Example:${NC}"
echo -e "ws://YOUR_IP:$WS_PORT/ssh"

echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-ssh 