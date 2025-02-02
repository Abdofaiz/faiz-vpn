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
echo -e "${CYAN}│${NC}              ${CYAN}SSH VPN MANAGER${NC}                     ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
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
    1) clear ; /usr/local/vpn-script/ssh/add-ssh.sh ;;
    2) clear ; /usr/local/vpn-script/ssh/trial-ssh.sh ;;
    3) clear ; /usr/local/vpn-script/ssh/renew-ssh.sh ;;
    4) clear ; /usr/local/vpn-script/ssh/del-ssh.sh ;;
    5) clear ; /usr/local/vpn-script/ssh/cek-ssh.sh ;;
    6) clear ; /usr/local/vpn-script/ssh/member-ssh.sh ;;
    7) clear ; /usr/local/vpn-script/ssh/del-expired.sh ;;
    8) clear ; /usr/local/vpn-script/ssh/autokill-ssh.sh ;;
    9) clear ; /usr/local/vpn-script/ssh/cek-multi.sh ;;
    10) clear ; /usr/local/vpn-script/ssh/restart-service.sh ;;
    0) clear ; menu ;;
    *) clear ; menu-ssh ;;
esac 