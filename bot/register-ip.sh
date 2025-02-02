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
IP_DB="/etc/bot/registered_ips.db"

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}            ${CYAN}REGISTER IP ADDRESS${NC}                   ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Get user input
read -p "IP Address : " ip
read -p "Client Name : " client
read -p "Duration (days) : " duration

# Validate IP format
if ! [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo -e "${RED}Error: Invalid IP format${NC}"
    exit 1
fi

# Check if IP exists
if grep -q "^### $ip" "$IP_DB"; then
    echo -e "${RED}Error: IP already registered${NC}"
    exit 1
fi

# Calculate expiry
exp=$(date -d "+$duration days" +"%Y-%m-%d")

# Save to database
echo "### $ip $client $exp" >> "$IP_DB"

# Success message
echo -e "${GREEN}IP Address registered successfully${NC}"
echo -e "IP      : $ip"
echo -e "Client  : $client"
echo -e "Expires : $exp" 