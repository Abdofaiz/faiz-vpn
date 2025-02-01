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
echo -e "${CYAN}│${NC}           ${CYAN}SERVER RESPONSE CHECK${NC}                  ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Get target URL
echo -ne "Enter target URL (e.g., http://example.com): "
read url

echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}Response Information${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check response time
echo -e "Response Time:"
time_result=$(curl -s -w "\nTime: %{time_total}s\nDNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTTFB: %{time_starttransfer}s\n" -o /dev/null "$url")
echo -e "$time_result" | while IFS= read -r line; do
    echo -e "           ${GREEN}$line${NC}"
done

# Check HTTP status
echo -e ""
echo -e "HTTP Status:"
status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
if [ "$status" -eq 200 ]; then
    echo -e "           ${GREEN}$status - OK${NC}"
else
    echo -e "           ${RED}$status - Error${NC}"
fi

# Check server headers
echo -e ""
echo -e "Server Headers:"
headers=$(curl -s -I "$url")
echo -e "$headers" | while IFS= read -r line; do
    echo -e "           ${GREEN}$line${NC}"
done

echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-bot 