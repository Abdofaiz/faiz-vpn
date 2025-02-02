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
L2TP_DB="/var/lib/crot/data-user-l2tp"
VERSION_FILE="/home/ver"

# Create required directories and files
mkdir -p /etc/ssh /etc/xray /var/lib/crot
touch $SSH_DB $XRAY_CONFIG $L2TP_DB

# Get System Information
get_system_info() {
    source /etc/os-release
    ARCH=$(uname -m)
    KERNEL=$(uname -r)
    CPU_MODEL=$(grep -m 1 "model name" /proc/cpuinfo | cut -d ':' -f2 | sed 's/^ *//')
    CPU_CORES=$(grep -c "processor" /proc/cpuinfo)
    CPU_FREQ=$(grep -m 1 "cpu MHz" /proc/cpuinfo | cut -d ':' -f2 | sed 's/^ *//')
    
    # Memory info in GB with 3 decimal places
    TOTAL_RAM=$(free -m | awk 'NR==2 {printf "%.3f", $2/1024}')
    USED_RAM=$(free -m | awk 'NR==2 {printf "%.3f", $3/1024}')
    SWAP_TOTAL=$(free -m | awk 'NR==4 {print $2}')
    
    # Disk info
    DISK_INFO=$(df -h / | awk 'NR==2 {print $2" (Used: "$3" Free: "$4")"}')
    
    # Network info
    DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "Not configured")
    IP=$(curl -s ipv4.icanhazip.com)
    ISP=$(curl -s ipinfo.io/org | tr -d '"')
    REGION=$(curl -s ipinfo.io/city),$(curl -s ipinfo.io/country)
    TIMEZONE=$(curl -s ipinfo.io/timezone)
    
    # Version
    VERSION=$(cat $VERSION_FILE 2>/dev/null || echo "1.0.0")
    echo "$VERSION" > $VERSION_FILE
}

# Get active users count
get_active_users() {
    SSH_USERS=$(grep -c "^###" $SSH_DB 2>/dev/null || echo "0")
    XRAY_USERS=$(grep -c "^###" $XRAY_CONFIG 2>/dev/null || echo "0")
    L2TP_USERS=$(grep -c "^###" $L2TP_DB 2>/dev/null || echo "0")
}

# Update system info
get_system_info
get_active_users

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}               ${CYAN}SCRIPT BY USER_LEGEND${NC}               ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}                  ${CYAN}SYS INFO${NC}                         ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${GREEN}OS SYSTEM${NC}    : $ID $VERSION_ID"
echo -e "${GREEN}ARCH${NC}         : $ARCH"
echo -e "${GREEN}KERNEL TYPE${NC}  : $KERNEL"
echo -e "${GREEN}CPU MODEL${NC}    : $CPU_MODEL"
echo -e "${GREEN}NUMBER CORES${NC} : $CPU_CORES"
echo -e "${GREEN}CPU FREQ${NC}     : $CPU_FREQ MHz"
echo -e "${GREEN}TOTAL RAM${NC}    : $TOTAL_RAM GB / $USED_RAM GB Used"
echo -e "${GREEN}TOTAL SWAP${NC}   : $SWAP_TOTAL MB"
echo -e "${GREEN}TOTAL DISK${NC}   : $DISK_INFO"
echo -e "${GREEN}DOMAIN${NC}       : $DOMAIN"
echo -e "${GREEN}SLOWDNS${NC}      : dns.$DOMAIN"
echo -e "${GREEN}IP ADDRESS${NC}   : $IP"
echo -e "${GREEN}ISP${NC}          : $ISP"
echo -e "${GREEN}REGION${NC}       : $REGION [$TIMEZONE]"
echo -e "${GREEN}SCRIPT VER${NC}   : $VERSION"
echo -e ""

# Account Info
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "     ${CYAN}SSH & OVPN${NC} : $SSH_USERS ${GREEN}ACTIVE${NC}"
echo -e "     ${CYAN}XRAY${NC}       : $XRAY_USERS ${GREEN}ACTIVE${NC}"
echo -e "     ${CYAN}L2TP${NC}       : $L2TP_USERS ${GREEN}ACTIVE${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Main Menu
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}                ${CYAN}MAIN MENU${NC}                         ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Menu Options
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} SSH Menu"
echo -e " ${GREEN}2)${NC} XRAY Menu"
echo -e " ${GREEN}3)${NC} ARGO Menu"
echo -e " ${GREEN}4)${NC} Security Menu"
echo -e " ${GREEN}5)${NC} Settings Menu"
echo -e " ${GREEN}6)${NC} Backup Menu"
echo -e " ${GREEN}7)${NC} Bot Menu"
echo -e " ${RED}0)${NC} Exit"
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
