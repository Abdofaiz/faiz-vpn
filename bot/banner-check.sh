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
echo -e "${CYAN}│${NC}             ${CYAN}SERVER BANNER CHECK${NC}                  ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Get target host and port
echo -ne "Enter target host: "
read host
echo -ne "Enter port [default: 80]: "
read port
port=${port:-80}

echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}Server Banner Information${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check HTTP banner
if response=$(curl -s -I "http://$host:$port"); then
    echo -e "HTTP Headers:"
    echo -e "$response" | while IFS= read -r line; do
        echo -e "           ${GREEN}$line${NC}"
    done
fi

# Check SSH banner
echo -e ""
echo -e "SSH Banner:"
if banner=$(timeout 5 nc -w5 $host 22 2>&1 | head -1); then
    echo -e "           ${GREEN}$banner${NC}"
else
    echo -e "           ${RED}No SSH banner available${NC}"
fi

# Check FTP banner
echo -e ""
echo -e "FTP Banner:"
if banner=$(timeout 5 nc -w5 $host 21 2>&1 | head -1); then
    echo -e "           ${GREEN}$banner${NC}"
else
    echo -e "           ${RED}No FTP banner available${NC}"
fi

echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-bot 