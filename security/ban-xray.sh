#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}               ${CYAN}BAN XRAY ACCOUNT${NC}                   ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# List active users
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}Active XRAY Users${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
grep -E "^### " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

# Get username to ban
echo -ne "Input Username to ban : "
read user

# Check if user exists
if grep -qw "^### $user" /etc/xray/config.json; then
    # Add to banned users list
    echo "$user" >> /etc/xray/.banned
    # Update XRAY config to remove user
    sed -i "/^### $user/,/^},{/d" /etc/xray/config.json
    systemctl restart xray
    echo -e ""
    echo -e "${GREEN}User ${YELLOW}$user${NC} ${GREEN}has been banned${NC}"
    echo -e "${GREEN}XRAY service has been restarted${NC}"
else
    echo -e ""
    echo -e "${RED}Error: User ${YELLOW}$user${NC} ${RED}does not exist${NC}"
fi

echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-security 