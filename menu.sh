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

# Paths
SCRIPT_DIR="/usr/local/vpn-script"
SSH_DB="/etc/ssh/.ssh.db"
XRAY_CONFIG="/etc/xray/config.json"
DOMAIN_FILE="/etc/xray/domain"
VERSION_FILE="/home/ver"

# Get System Information
get_system_info() {
    source /etc/os-release
    ARCH=$(uname -m)
    KERNEL=$(uname -r)
    CPU_MODEL=$(grep -m 1 "model name" /proc/cpuinfo | cut -d ':' -f2 | sed 's/^ *//')
    CPU_CORES=$(grep -c "processor" /proc/cpuinfo)
    CPU_FREQ=$(grep -m 1 "cpu MHz" /proc/cpuinfo | cut -d ':' -f2 | sed 's/^ *//')
    TOTAL_RAM=$(free -m | awk 'NR==2 {printf "%.3f", $2/1024}')
    USED_RAM=$(free -m | awk 'NR==2 {printf "%.3f", $3/1024}')
    DISK_INFO=$(df -h / | awk 'NR==2 {print $2" (Used: "$3" Free: "$4")"}')
}

# Get active users count
get_active_users() {
    SSH_USERS=$(grep -c "^###" $SSH_DB 2>/dev/null || echo "0")
    XRAY_USERS=$(grep -c "^###" $XRAY_CONFIG 2>/dev/null || echo "0")
}

# Update system info
get_system_info
get_active_users

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}                ${CYAN}VPN MANAGER${NC}                       ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# System Info
echo -e "${CYAN}System Information${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "OS      : $ID $VERSION_ID"
echo -e "CPU     : $CPU_MODEL ($CPU_CORES cores)"
echo -e "Memory  : $USED_RAM GB / $TOTAL_RAM GB"
echo -e "Storage : $DISK_INFO"
echo -e ""

# Active Users
echo -e "${CYAN}Active Users${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "SSH     : $SSH_USERS users"
echo -e "XRAY    : $XRAY_USERS users"
echo -e ""

# Menu
echo -e "${CYAN}Main Menu${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}1)${NC} SSH Menu"
echo -e "${GREEN}2)${NC} XRAY Menu"
echo -e "${GREEN}3)${NC} ARGO Menu"
echo -e "${GREEN}4)${NC} Security Menu"
echo -e "${GREEN}5)${NC} Settings Menu"
echo -e "${GREEN}6)${NC} Backup Menu"
echo -e "${GREEN}7)${NC} Bot Menu"
echo -e "${RED}0)${NC} Exit"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-7]: "
read opt

case $opt in
    1) clear ; menu-ssh ;;
    2) clear ; menu-xray ;;
    3) clear ; menu-argo ;;
    4) clear ; menu-security ;;
    5) clear ; menu-settings ;;
    6) clear ; menu-backup ;;
    7) clear ; menu-bot ;;
    0) clear ; exit ;;
    *) clear ; menu ;;
esac 