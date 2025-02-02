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
echo -e "${CYAN}│${NC}               ${CYAN}VLESS MENU${NC}                         ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Menu Options
echo -e " ${GREEN}1)${NC} Create Vless WS Account"
echo -e " ${GREEN}2)${NC} Create Vless gRPC Account"
echo -e " ${GREEN}3)${NC} Create Vless XTLS Account"
echo -e " ${GREEN}4)${NC} Extend Vless Account"
echo -e " ${GREEN}5)${NC} Delete Vless Account"
echo -e " ${GREEN}6)${NC} Check Vless User Login"
echo -e " ${RED}0)${NC} Back to XRAY Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-6]: "
read opt

case $opt in
    1) clear ; add-vless-ws ;;
    2) clear ; add-vless-grpc ;;
    3) clear ; add-vless-xtls ;;
    4) clear ; extend-vless ;;
    5) clear ; del-vless ;;
    6) clear ; cek-vless ;;
    0) clear ; menu-xray ;;
    *) clear ; menu-vless ;;
esac 