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
echo -e "${CYAN}│${NC}               ${CYAN}CDN IP CHECKER${NC}                     ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Get domain/IP to check
echo -ne "Enter domain/IP to check: "
read target

# Check if input is IP or domain
if [[ $target =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    host_type="IP"
else
    host_type="Domain"
fi

echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}CDN Information${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Type       : ${GREEN}$host_type${NC}"
echo -e "Target     : ${GREEN}$target${NC}"

# Get all IPs if domain
if [ "$host_type" == "Domain" ]; then
    echo -e ""
    echo -e "Resolving IPs:"
    for ip in $(dig +short $target); do
        echo -e "           ${GREEN}$ip${NC}"
    done
fi

# Check for common CDN headers
echo -e ""
echo -e "CDN Detection:"
response=$(curl -s -I $target)

# Check for Cloudflare
if echo "$response" | grep -qi "cloudflare"; then
    echo -e "           ${GREEN}Cloudflare detected${NC}"
fi

# Check for Akamai
if echo "$response" | grep -qi "akamai"; then
    echo -e "           ${GREEN}Akamai detected${NC}"
fi

# Check for Fastly
if echo "$response" | grep -qi "fastly"; then
    echo -e "           ${GREEN}Fastly detected${NC}"
fi

# Check for Cloudfront
if echo "$response" | grep -qi "cloudfront"; then
    echo -e "           ${GREEN}Cloudfront detected${NC}"
fi

echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-bot 