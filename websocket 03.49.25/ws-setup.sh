#!/bin/bash
# WebSocket Setup Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Install Nginx
echo -e "${BLUE}Installing Nginx...${NC}"
apt install -y nginx
systemctl enable nginx
systemctl start nginx

# Configure Nginx for WebSocket
echo -e "${BLUE}Configuring Nginx for WebSocket...${NC}"
cat > /etc/nginx/conf.d/xray.conf <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name _;
    
    location / {
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    
    location /xray {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# Configure SSL (if domain is set)
if [ ! -z "$DOMAIN" ]; then
    echo -e "${BLUE}Setting up SSL for $DOMAIN...${NC}"
    apt install -y certbot python3-certbot-nginx
    certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN
fi

# Test and restart Nginx
nginx -t
systemctl restart nginx

# Setup WebSocket service
echo -e "${BLUE}Setting up WebSocket service...${NC}"
cat > /etc/systemd/system/ws-service.service <<EOF
[Unit]
Description=WebSocket Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ws-server
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Create WebSocket server script
cat > /usr/local/bin/ws-server <<EOF
#!/usr/bin/env python3
import asyncio
import websockets
import json
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    filename='/var/log/autoscript/websocket.log'
)

async def handle_connection(websocket, path):
    try:
        async for message in websocket:
            data = json.loads(message)
            # Handle WebSocket messages
            response = {'status': 'ok', 'message': 'received'}
            await websocket.send(json.dumps(response))
    except Exception as e:
        logging.error(f"Error: {str(e)}")

async def main():
    async with websockets.serve(handle_connection, "127.0.0.1", 10000):
        await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())
EOF

chmod +x /usr/local/bin/ws-server
systemctl enable ws-service
systemctl start ws-service

echo -e "${GREEN}WebSocket setup completed${NC}" 