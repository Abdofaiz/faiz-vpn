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

# Clear screen
clear

# Banner
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}               ${CYAN}VMESS MENU${NC}                         ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Menu Options
echo -e " ${GREEN}1)${NC} Create Vmess WS Account"
echo -e " ${GREEN}2)${NC} Create Vmess gRPC Account"
echo -e " ${GREEN}3)${NC} Create Vmess TCP Account"
echo -e " ${GREEN}4)${NC} Extend Vmess Account"
echo -e " ${GREEN}5)${NC} Delete Vmess Account"
echo -e " ${GREEN}6)${NC} Check Vmess User Login"
echo -e " ${RED}0)${NC} Back to XRAY Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-6]: "
read opt

case $opt in
    1) clear ; add-vmess-ws ;;
    2) clear ; add-vmess-grpc ;;
    3) clear ; add-vmess-tcp ;;
    4) clear ; extend-vmess ;;
    5) clear ; del-vmess ;;
    6) clear ; cek-vmess ;;
    0) clear ; menu-xray ;;
    *) clear ; menu-vmess ;;
esac 