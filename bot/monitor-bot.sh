#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
NC='\033[0m'

# Config paths
BOT_CONFIG="/etc/bot/.config"
TELEGRAM_TOKEN=$(cat "$BOT_CONFIG/token")
ADMIN_ID=$(cat "$BOT_CONFIG/admin_id")

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}             ${CYAN}TELEGRAM BOT MONITOR${NC}                 ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Check services
check_service() {
    if systemctl is-active --quiet $1; then
        echo -e "$1: ${GREEN}Running${NC}"
    else
        echo -e "$1: ${RED}Not Running${NC}"
        # Send Telegram alert
        message="⚠️ Service $1 is down!"
        curl -s "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
            -d "chat_id=$ADMIN_ID" \
            -d "text=$message" \
            -d "parse_mode=HTML"
    fi
}

echo -e "Service Status:"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
check_service "ssh"
check_service "dropbear"
check_service "stunnel4"
check_service "xray"
check_service "nginx"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" 