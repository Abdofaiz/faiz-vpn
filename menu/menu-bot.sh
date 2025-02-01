#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script paths
BOT_DIR="/usr/local/vpn-script/bot"

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}               ${CYAN}BOT MENU${NC}                           ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Menu Options
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Register IP"
echo -e " ${GREEN}2)${NC} IP Lookup"
echo -e " ${GREEN}3)${NC} CDN Check"
echo -e " ${GREEN}4)${NC} Banner Check"
echo -e " ${GREEN}5)${NC} Response Check"
echo -e " ${GREEN}6)${NC} SSL Certificate Check"
echo -e " ${GREEN}7)${NC} Bot Settings"
echo -e " ${GREEN}8)${NC} Schedule Automated Backups"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-8]: "
read opt

case $opt in
    1) clear ; $BOT_DIR/register-ip.sh ;;
    2) clear ; $BOT_DIR/ip-lookup.sh ;;
    3) clear ; $BOT_DIR/cdn-check.sh ;;
    4) clear ; $BOT_DIR/banner-check.sh ;;
    5) clear ; $BOT_DIR/response-check.sh ;;
    6) clear ; $BOT_DIR/cert-check.sh ;;
    7) clear ; $BOT_DIR/bot-settings.sh ;;
    8) clear ; $BOT_DIR/schedule-backup.sh ;;
    0) clear ; menu ;;
    *) clear ; menu-bot ;;
esac 