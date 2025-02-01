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

# Get System Information
domain=$(cat /etc/xray/domain)
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10 )
CITY=$(curl -s ipinfo.io/city )
WKT=$(curl -s ipinfo.io/timezone )
IPVPS=$(curl -s ipv4.icanhazip.com)
tram=$(free -m | awk 'NR==2 {print $2}')
swap=$(free -m | awk 'NR==4 {print $2}')
freq=$(awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo)
cores=$(awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo)
cname=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo)
kernel=$(uname -r)
RAM=$(free -m | awk 'NR==2 {print $2}')
USAGERAM=$(free -m | awk 'NR==2 {print $3}')
MEMOFREE=$(printf '%.3f' "$(echo "scale=3; $RAM/1024" | bc)")
MEMOUSED=$(printf '%.3f' "$(echo "scale=3; $USAGERAM/1024" | bc)")
totalgb=$(df -h / | awk 'NR==2 {print $2}')
usedgb=$(df -h / | awk 'NR==2 {print $3}')
freegb=$(df -h / | awk 'NR==2 {print $4}')

# Clear screen
clear

# Banner
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}               ${CYAN}SCRIPT BY USER_LEGEND${NC}               ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}                  ${CYAN}SYS INFO${NC}                         ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${GREEN}OS SYSTEM${NC}    : $ID $VERSION_ID"
echo -e "${GREEN}ARCH${NC}         : $(uname -m)"
echo -e "${GREEN}KERNEL TYPE${NC}  : $kernel"
echo -e "${GREEN}CPU MODEL${NC}    : $cname"
echo -e "${GREEN}NUMBER CORES${NC} : $cores"
echo -e "${GREEN}CPU FREQ${NC}     : $freq MHz"
echo -e "${GREEN}TOTAL RAM${NC}    : ${MEMOFREE} GB / ${MEMOUSED} GB Used"
echo -e "${GREEN}TOTAL SWAP${NC}   : $swap MB"
echo -e "${GREEN}TOTAL DISK${NC}   : $totalgb (Used: $usedgb Free: $freegb)"
echo -e "${GREEN}DOMAIN${NC}       : $domain"
echo -e "${GREEN}SLOWDNS${NC}      : dns.$domain"
echo -e "${GREEN}IP ADDRESS${NC}   : $IPVPS"
echo -e "${GREEN}ISP${NC}          : $ISP"
echo -e "${GREEN}REGION${NC}       : $CITY [$WKT]"
echo -e "${GREEN}SCRIPT VER${NC}   : $(cat /home/ver)"
echo -e ""

# Account Info
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "     ${CYAN}SSH & OVPN${NC} : $(grep -c -E "^### " "/etc/ssh/.ssh.db") ${GREEN}ACTIVE${NC}"
echo -e "     ${CYAN}XRAY${NC}       : $(grep -c -E "^### " "/etc/xray/config.json") ${GREEN}ACTIVE${NC}"
echo -e "     ${CYAN}L2TP${NC}       : $(grep -c -E "^### " "/var/lib/crot/data-user-l2tp") ${GREEN}ACTIVE${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Main Menu
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}                  ${CYAN}MAIN MENU${NC}                        ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e " ${GREEN}1)${NC} MENU SSH & OVPN"
echo -e " ${GREEN}2)${NC} MENU XRAY"
echo -e " ${GREEN}3)${NC} MENU ARGO"
echo -e " ${GREEN}4)${NC} MENU SECURITY"
echo -e " ${GREEN}5)${NC} MENU SETTINGS"
echo -e " ${GREEN}6)${NC} BACKUP & RESTORE"
echo -e " ${GREEN}7)${NC} STATUS SERVICES"
echo -e " ${GREEN}8)${NC} UPDATE SCRIPT"
echo -e " ${RED}0)${NC} Exit"
echo -e ""
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -ne "Please select an option [0-8]: "
read opt

case $opt in
    1) clear ; menu-ssh ;;
    2) clear ; menu-xray ;;
    3) clear ; menu-argo ;;
    4) clear ; menu-security ;;
    5) clear ; menu-settings ;;
    6) clear ; menu-backup ;;
    7) clear ; running ;;
    8) clear ; update ;;
    0) clear ; exit ;;
    *) clear ; menu ;;
esac
