#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}               ${CYAN}SSH MANAGER${NC}                        ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Create Account"
echo -e " ${GREEN}2)${NC} Delete Account"
echo -e " ${GREEN}3)${NC} Extend Account"
echo -e " ${GREEN}4)${NC} Check User Login"
echo -e " ${GREEN}5)${NC} List Member"
echo -e " ${GREEN}6)${NC} Delete Expired"
echo -e " ${GREEN}7)${NC} Auto Kill Multi Login"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-7]: "
read opt

case $opt in
    1) clear ; /usr/local/vpn-script/ssh/add-ssh.sh ;;
    2) clear ; /usr/local/vpn-script/ssh/del-ssh.sh ;;
    3) clear ; /usr/local/vpn-script/ssh/renew-ssh.sh ;;
    4) clear ; /usr/local/vpn-script/ssh/cek-ssh.sh ;;
    5) clear ; /usr/local/vpn-script/ssh/list-ssh.sh ;;
    6) clear ; /usr/local/vpn-script/ssh/del-exp.sh ;;
    7) clear ; /usr/local/vpn-script/ssh/autokill.sh ;;
    0) clear ; menu ;;
    *) clear ; menu-ssh ;;
esac 