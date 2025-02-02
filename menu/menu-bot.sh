#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}                ${CYAN}BOT FEATURES${NC}                      ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Menu Options
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}Bot Management${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Register IP Address"
echo -e " ${GREEN}2)${NC} IP Lookup"
echo -e " ${GREEN}3)${NC} Check IP to CDN"
echo -e " ${GREEN}4)${NC} Server Banner Check"
echo -e " ${GREEN}5)${NC} Server Response Check"
echo -e " ${GREEN}6)${NC} SSL Certificate Check"
echo -e " ${GREEN}7)${NC} Bot Settings"
echo -e " ${GREEN}8)${NC} Schedule Automated Backups"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-8]: "
read opt

case $opt in
    1) clear ; ./bot/register-ip.sh ;;
    2) clear ; ./bot/ip-lookup.sh ;;
    3) clear ; ./bot/cdn-check.sh ;;
    4) clear ; ./bot/banner-check.sh ;;
    5) clear ; ./bot/response-check.sh ;;
    6) clear ; ./bot/cert-check.sh ;;
    7) clear ; ./bot/bot-settings.sh ;;
    8) clear ; ./bot/schedule-backup.sh ;;
    0) clear ; ./menu.sh ;;
    *) clear ; ./menu/menu-bot.sh ;;
esac
echo -e " ${GREEN}1)${NC} Register IP Address"
echo -e " ${GREEN}2)${NC} IP Lookup"
echo -e " ${GREEN}3)${NC} Check IP to CDN"
echo -e " ${GREEN}4)${NC} Server Banner Check"
echo -e " ${GREEN}5)${NC} Server Response Check"
echo -e " ${GREEN}6)${NC} SSL Certificate Check"
echo -e " ${GREEN}7)${NC} Bot Settings"
+ echo -e " ${GREEN}8)${NC} User Management"
+ echo -e " ${GREEN}9)${NC} Bandwidth Monitor"
+ echo -e " ${GREEN}10)${NC} Generate Report"