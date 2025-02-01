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

# OS Information
source /etc/os-release
source /root/.myipvps

# Clear screen
clear

# Banner
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}              ${CYAN}SSH VPN MANAGER${NC}                     ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Menu Options
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}Connection Types${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Direct SSH (Default Port)"
echo -e " ${GREEN}2)${NC} HTTP Payload (Port 80)"
echo -e " ${GREEN}3)${NC} SSL/TLS Payload (Port 443)"
echo -e " ${GREEN}4)${NC} Websocket HTTP (Port 80)"
echo -e " ${GREEN}5)${NC} Websocket SSL/TLS (Port 443)"
echo -e " ${GREEN}6)${NC} Custom Payload Configuration"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -ne "Select an option [0-6]: "
read opt

case $opt in
    1) clear ; ./protocols/ssh-direct.sh ;;
    2) clear ; ./protocols/ssh-http.sh ;;
    3) clear ; ./protocols/ssh-ssl.sh ;;
    4) clear ; ./protocols/websocket-http.sh ;;
    5) clear ; ./protocols/websocket-ssl.sh ;;
    6) clear ; ./protocols/custom-payload.sh ;;
    0) clear ; ./menu.sh ;;
    *) clear ; ./menu/menu-ssh.sh ;;
esac 