#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script paths
PROTO_DIR="/usr/local/vpn-script/protocols"

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}              ${CYAN}XRAY MANAGER${NC}                        ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Menu Options
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Install XRAY"
echo -e " ${GREEN}2)${NC} VLESS Menu"
echo -e " ${GREEN}3)${NC} VMESS Menu"
echo -e " ${GREEN}4)${NC} Trojan Menu"
echo -e " ${GREEN}5)${NC} List All Members"
echo -e " ${GREEN}6)${NC} Check Running Services"
echo -e " ${GREEN}7)${NC} Update Certificate"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-7]: "
read opt

case $opt in
    1) exec bash "$PROTO_DIR/xray.sh" install ;;
    2) exec bash "$PROTO_DIR/xray.sh" vless-menu ;;
    3) exec bash "$PROTO_DIR/xray.sh" vmess-menu ;;
    4) exec bash "$PROTO_DIR/xray.sh" trojan-menu ;;
    5) exec bash "$PROTO_DIR/xray.sh" list-all ;;
    6) exec bash "$PROTO_DIR/xray.sh" status ;;
    7) exec bash "$PROTO_DIR/xray.sh" update-cert ;;
    0) exec menu ;;
    *) exec menu-xray ;;
esac 