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
echo -e " ${GREEN}1)${NC} Create XRAY Account"
echo -e " ${GREEN}2)${NC} Trial XRAY Account"
echo -e " ${GREEN}3)${NC} Extend XRAY Account"
echo -e " ${GREEN}4)${NC} Delete XRAY Account"
echo -e " ${GREEN}5)${NC} Check User Login"
echo -e " ${GREEN}6)${NC} List Member XRAY"
echo -e " ${GREEN}7)${NC} Renew Certificate XRAY"
echo -e " ${GREEN}8)${NC} Check XRAY Config"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-8]: "
read opt

case $opt in
    1) clear ; $PROTO_DIR/xray.sh create ;;
    2) clear ; $PROTO_DIR/xray.sh trial ;;
    3) clear ; $PROTO_DIR/xray.sh extend ;;
    4) clear ; $PROTO_DIR/xray.sh delete ;;
    5) clear ; $PROTO_DIR/xray.sh check ;;
    6) clear ; $PROTO_DIR/xray.sh list ;;
    7) clear ; $PROTO_DIR/xray.sh cert ;;
    8) clear ; $PROTO_DIR/xray.sh config ;;
    0) clear ; menu ;;
    *) clear ; menu-xray ;;
esac 