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

# Database path
IP_DB="/etc/bot/registered_ips.db"

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}              ${CYAN}IP LOOKUP${NC}                           ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Get IP input
read -p "Enter IP to lookup: " ip

# Check if IP exists
if ! grep -q "^### $ip" "$IP_DB"; then
    echo -e "${RED}IP not found in database${NC}"
    exit 1
fi

# Get IP info
info=$(grep "^### $ip" "$IP_DB")
client=$(echo $info | cut -d' ' -f3)
exp=$(echo $info | cut -d' ' -f4)

# Show info
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "IP Address : $ip"
echo -e "Client     : $client"
echo -e "Expires    : $exp"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" 