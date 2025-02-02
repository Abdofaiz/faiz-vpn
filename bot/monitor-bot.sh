#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Config files
BOT_CONFIG="/etc/bot/.config/bot.conf"
TOKEN=$(grep "BOT_TOKEN" $BOT_CONFIG | cut -d'=' -f2)
ADMIN_ID=$(grep "ADMIN_ID" $BOT_CONFIG | cut -d'=' -f2)

# Check services
check_service() {
    if systemctl is-active --quiet $1; then
        echo -e "${GREEN}Active${NC}"
    else
        echo -e "${RED}Inactive${NC}"
    fi
}

# Send message to Telegram
send_message() {
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d "chat_id=$ADMIN_ID" \
        -d "text=$1" \
        -d "parse_mode=HTML"
}

# Monitor services
echo -e "Checking services..."
XRAY_STATUS=$(check_service xray)
NGINX_STATUS=$(check_service nginx)
DROPBEAR_STATUS=$(check_service dropbear)

# Send status to admin
MESSAGE="🖥 <b>Server Status Report</b>
━━━━━━━━━━━━━━━━
🔸 XRAY: $XRAY_STATUS
🔸 NGINX: $NGINX_STATUS
🔸 DROPBEAR: $DROPBEAR_STATUS
━━━━━━━━━━━━━━━━"

send_message "$MESSAGE" 