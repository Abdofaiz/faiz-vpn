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
echo -e "${CYAN}│${NC}              ${CYAN}SSH VPN MANAGER${NC}                     ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Menu Options
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Create SSH Account"
echo -e " ${GREEN}2)${NC} Trial SSH Account"
echo -e " ${GREEN}3)${NC} Renew SSH Account"
echo -e " ${GREEN}4)${NC} Delete SSH Account"
echo -e " ${GREEN}5)${NC} Check User Login"
echo -e " ${GREEN}6)${NC} List Member SSH"
echo -e " ${GREEN}7)${NC} Delete User Expired"
echo -e " ${GREEN}8)${NC} Set up Autokill SSH"
echo -e " ${GREEN}9)${NC} Check User Multi Login"
echo -e " ${GREEN}10)${NC} Restart All Service"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-10]: "
read opt

case $opt in
    1) bash "$PROTO_DIR/ssh.sh" create ;;
    2) bash "$PROTO_DIR/ssh.sh" trial ;;
    3) bash "$PROTO_DIR/ssh.sh" renew ;;
    4) bash "$PROTO_DIR/ssh.sh" delete ;;
    5) bash "$PROTO_DIR/ssh.sh" check ;;
    6) bash "$PROTO_DIR/ssh.sh" list ;;
    7) bash "$PROTO_DIR/ssh.sh" expired ;;
    8) bash "$PROTO_DIR/ssh.sh" autokill ;;
    9) bash "$PROTO_DIR/ssh.sh" multi ;;
    10) bash "$PROTO_DIR/ssh.sh" restart ;;
    0) clear ; menu ;;
    *) clear ; menu-ssh ;;
esac 