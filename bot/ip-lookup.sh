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
echo -e "${CYAN}│${NC}                 ${CYAN}IP LOOKUP${NC}                        ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Get IP to lookup
echo -ne "Enter IP address to lookup: "
read ip_address

# Validate IP format
if [[ ! "$ip_address" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e ""
    echo -e "${RED}Invalid IP address format${NC}"
    echo -e ""
    read -n 1 -s -r -p "Press any key to back on menu"
    menu-bot
    exit 1
fi

# Perform IP lookup
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}IP Information${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Get IP info using multiple APIs for redundancy
if result=$(curl -s "http://ip-api.com/json/$ip_address"); then
    country=$(echo $result | jq -r '.country')
    region=$(echo $result | jq -r '.regionName')
    city=$(echo $result | jq -r '.city')
    isp=$(echo $result | jq -r '.isp')
    org=$(echo $result | jq -r '.org')
    asn=$(echo $result | jq -r '.as')
    
    echo -e "IP Address : ${GREEN}$ip_address${NC}"
    echo -e "Country    : ${GREEN}$country${NC}"
    echo -e "Region     : ${GREEN}$region${NC}"
    echo -e "City       : ${GREEN}$city${NC}"
    echo -e "ISP        : ${GREEN}$isp${NC}"
    echo -e "Org        : ${GREEN}$org${NC}"
    echo -e "ASN        : ${GREEN}$asn${NC}"
else
    echo -e "${RED}Failed to lookup IP information${NC}"
fi

echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-bot 