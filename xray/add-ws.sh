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

# Config path
XRAY_CONFIG="/etc/xray/config.json"

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}           ${CYAN}CREATE XRAY WEBSOCKET${NC}                  ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Get user input
read -p "Username : " user
read -p "Duration (days) : " duration

# Generate UUID
uuid=$(uuidgen)
exp=$(date -d "+$duration days" +"%Y-%m-%d")

# Add to XRAY config
jq --arg user "$user" \
   --arg uuid "$uuid" \
   --arg exp "$exp" \
   '.inbounds[0].settings.clients += [{
      "id": $uuid,
      "alterId": 0,
      "email": $user,
      "exp": $exp
    }]' $XRAY_CONFIG > /tmp/tmp.json && mv /tmp/tmp.json $XRAY_CONFIG

# Restart XRAY
systemctl restart xray

# Success message
clear
echo -e "${GREEN}Websocket Account Created Successfully${NC}"
echo -e "Username : $user"
echo -e "UUID     : $uuid"
echo -e "Protocol : Websocket"
echo -e "Port TLS : 443"
echo -e "Port     : 80"
echo -e "Expires  : $exp" 