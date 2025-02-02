#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}               ${CYAN}SYSTEM TOOLS${NC}                       ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Speedtest"
echo -e " ${GREEN}2)${NC} System Information"
echo -e " ${GREEN}3)${NC} Check Memory Usage"
echo -e " ${GREEN}4)${NC} Check Bandwidth Usage"
echo -e " ${GREEN}5)${NC} Check Service Status"
echo -e " ${GREEN}6)${NC} Restart All Services"
echo -e " ${GREEN}7)${NC} Update Script"
echo -e " ${GREEN}8)${NC} Clear Log Files"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-8]: "
read opt

case $opt in
    1) clear ; /usr/local/vpn-script/tools/speedtest.sh ;;
    2) clear ; /usr/local/vpn-script/tools/sysinfo.sh ;;
    3) clear ; /usr/local/vpn-script/tools/ram.sh ;;
    4) clear ; /usr/local/vpn-script/tools/bandwidth.sh ;;
    5) clear ; /usr/local/vpn-script/tools/service.sh ;;
    6) clear ; /usr/local/vpn-script/tools/restart.sh ;;
    7) clear ; /usr/local/vpn-script/tools/update.sh ;;
    8) clear ; /usr/local/vpn-script/tools/clear-log.sh ;;
    0) clear ; menu ;;
    *) clear ; menu-tools ;;
esac 