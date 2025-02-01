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
echo -e " ${GREEN}2)${NC} Create Account"
echo -e " ${GREEN}3)${NC} Delete Account"
echo -e " ${GREEN}4)${NC} List Members"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-4]: "
read opt

case $opt in
    1) exec bash "$PROTO_DIR/xray.sh" install ;;
    2) exec bash "$PROTO_DIR/xray.sh" create ;;
    3) exec bash "$PROTO_DIR/xray.sh" delete ;;
    4) exec bash "$PROTO_DIR/xray.sh" list ;;
    0) exec menu ;;
    *) exec menu-xray ;;
esac 