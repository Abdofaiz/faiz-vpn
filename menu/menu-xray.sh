#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# OS Information
source /etc/os-release
source /root/.myipvps

# Clear screen
clear

# Banner
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}              ${CYAN}XRAY VPN MANAGER${NC}                   ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} VMESS Menu"
echo -e " ${GREEN}2)${NC} VLESS Menu"
echo -e " ${GREEN}3)${NC} Trojan Menu"
echo -e " ${GREEN}4)${NC} Check Running Services"
echo -e " ${GREEN}5)${NC} Check User Login"
echo -e " ${GREEN}6)${NC} Check Port Status"
echo -e " ${GREEN}7)${NC} Restart All Services"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-7]: "
read opt

case $opt in
    1) clear ; menu-vmess ;;
    2) clear ; menu-vless ;;
    3) clear ; menu-trojan ;;
    4) clear ; /usr/local/vpn-script/xray/check-services.sh ;;
    5) clear ; /usr/local/vpn-script/xray/check-login.sh ;;
    6) clear ; /usr/local/vpn-script/xray/check-port.sh ;;
    7) clear ; /usr/local/vpn-script/xray/restart.sh ;;
    0) clear ; menu ;;
    *) clear ; menu-xray ;;
esac 