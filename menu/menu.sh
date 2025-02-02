#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Paths
SCRIPT_DIR="/usr/local/vpn-script"
SSH_DB="/etc/ssh/.ssh.db"
XRAY_CONFIG="/etc/xray/config.json"
L2TP_DB="/var/lib/crot/data-user-l2tp"
VERSION_FILE="/home/ver"

# Create required directories and files
mkdir -p /etc/ssh /etc/xray /var/lib/crot
touch $SSH_DB $XRAY_CONFIG $L2TP_DB

# Get system info
source /etc/os-release
IP=$(curl -s ipv4.icanhazip.com)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "Not Configured")

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}               ${CYAN}VPN MANAGER${NC}                        ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}                 ${CYAN}SYSTEM INFO${NC}                      ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${GREEN}OS Version${NC}  : $PRETTY_NAME"
echo -e "${GREEN}IP Address${NC}  : $IP"
echo -e "${GREEN}Domain${NC}      : $DOMAIN"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} SSH & OpenVPN Menu"
echo -e " ${GREEN}2)${NC} XRAY Menu"
echo -e " ${GREEN}3)${NC} ARGO Menu"
echo -e " ${GREEN}4)${NC} Security Menu"
echo -e " ${GREEN}5)${NC} Settings Menu"
echo -e " ${GREEN}6)${NC} Backup Menu"
echo -e " ${GREEN}7)${NC} Bot Menu"
echo -e " ${GREEN}8)${NC} System Tools"
echo -e " ${RED}0)${NC} Exit"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-8]: "
read opt

case $opt in
    1) clear ; menu-ssh ;;
    2) clear ; menu-xray ;;
    3) clear ; menu-argo ;;
    4) clear ; menu-security ;;
    5) clear ; menu-settings ;;
    6) clear ; menu-backup ;;
    7) clear ; menu-bot ;;
    8) clear ; menu-tools ;;
    0) clear ; exit ;;
    *) clear ; menu ;;
esac
