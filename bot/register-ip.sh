#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
BOT_TOKEN=$(cat /etc/bot/.token)
ADMIN_ID=$(cat /etc/bot/.admin)
API_URL="https://api.telegram.org/bot$BOT_TOKEN"

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}             ${CYAN}REGISTER IP ADDRESS${NC}                  ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Get current IP
CURRENT_IP=$(curl -s ipv4.icanhazip.com)
echo -e "Current IP: ${GREEN}$CURRENT_IP${NC}"
echo -e ""

# Check if IP is already registered
if [ -f "/etc/bot/.registered_ips" ]; then
    if grep -q "$CURRENT_IP" "/etc/bot/.registered_ips"; then
        echo -e "${YELLOW}This IP is already registered${NC}"
        echo -e ""
        read -n 1 -s -r -p "Press any key to back on menu"
        menu-bot
        exit 0
    fi
fi

# Get registration details
echo -ne "Enter your name: "
read name
echo -ne "Enter your email: "
read email

# Validate email format
if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
    echo -e ""
    echo -e "${RED}Invalid email format${NC}"
    echo -e ""
    read -n 1 -s -r -p "Press any key to back on menu"
    menu-bot
    exit 1
fi

# Send registration request to admin via bot
MESSAGE="New IP Registration Request:
Name: $name
Email: $email
IP: $CURRENT_IP
Date: $(date)"

curl -s -X POST "$API_URL/sendMessage" \
    -d "chat_id=$ADMIN_ID" \
    -d "text=$MESSAGE" \
    -d "parse_mode=HTML"

# Save registration request
echo "$CURRENT_IP|$name|$email|$(date +%Y-%m-%d)" >> "/etc/bot/.pending_ips"

echo -e ""
echo -e "${GREEN}Registration request sent to admin${NC}"
echo -e "${YELLOW}Please wait for approval${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-bot 