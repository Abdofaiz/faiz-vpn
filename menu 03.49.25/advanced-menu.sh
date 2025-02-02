#!/bin/bash
# Advanced VPS Menu System

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Main Menu
show_main_menu() {
    clear
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           VPS MANAGER MENU            ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo -e "1) SSH & WebSocket Manager"
    echo -e "2) XRAY Manager"
    echo -e "3) OpenVPN Manager"
    echo -e "4) L2TP Manager"
    echo -e "5) Service Manager"
    echo -e "6) System Tools"
    echo -e "7) Security Center"
    echo -e "8) Backup & Restore"
    echo -e "0) Exit"
}

# SSH & WebSocket Menu
ssh_ws_menu() {
    clear
    echo -e "${BLUE}=== SSH & WebSocket Manager ===${NC}"
    echo -e "1) Create SSH User"
    echo -e "2) Delete SSH User"
    echo -e "3) Extend User Expiry"
    echo -e "4) View SSH Users"
    echo -e "5) Monitor SSH Users"
    echo -e "6) WebSocket Settings"
    echo -e "7) Change SSH Port"
    echo -e "8) Change SSH Banner"
    echo -e "0) Back"
}

# XRAY Menu
xray_menu() {
    clear
    echo -e "${BLUE}=== XRAY Manager ===${NC}"
    echo -e "1) Add VMESS User"
    echo -e "2) Add VLESS User"
    echo -e "3) Add TROJAN User"
    echo -e "4) Delete User"
    echo -e "5) View All Users"
    echo -e "6) Show Config"
    echo -e "7) Change Port"
    echo -e "8) Renew Certificate"
    echo -e "0) Back"
}

# OpenVPN Menu
openvpn_menu() {
    clear
    echo -e "${BLUE}=== OpenVPN Manager ===${NC}"
    echo -e "1) Create User"
    echo -e "2) Delete User"
    echo -e "3) Extend User"
    echo -e "4) View Users"
    echo -e "5) Monitor Users"
    echo -e "6) Change Port"
    echo -e "7) Generate Config"
    echo -e "0) Back"
}

# Service Manager Menu
service_menu() {
    clear
    echo -e "${BLUE}=== Service Manager ===${NC}"
    echo -e "1) View All Services"
    echo -e "2) Start Service"
    echo -e "3) Stop Service"
    echo -e "4) Restart Service"
    echo -e "5) View Service Logs"
    echo -e "6) View Port Status"
    echo -e "7) Change Ports"
    echo -e "8) Restart All Services"
    echo -e "0) Back"
}

# System Tools Menu
system_menu() {
    clear
    echo -e "${BLUE}=== System Tools ===${NC}"
    echo -e "1) System Information"
    echo -e "2) Network Tools"
    echo -e "3) Bandwidth Monitor"
    echo -e "4) Speed Test"
    echo -e "5) Clear Cache"
    echo -e "6) Update System"
    echo -e "7) Optimize System"
    echo -e "8) Change Timezone"
    echo -e "0) Back"
}

# Security Center Menu
security_menu() {
    clear
    echo -e "${BLUE}=== Security Center ===${NC}"
    echo -e "1) View Login History"
    echo -e "2) Block IP"
    echo -e "3) Unblock IP"
    echo -e "4) View Blocked IPs"
    echo -e "5) Fail2Ban Settings"
    echo -e "6) Change Passwords"
    echo -e "7) SSL Certificate"
    echo -e "8) Firewall Settings"
    echo -e "0) Back"
}

# Backup & Restore Menu
backup_menu() {
    clear
    echo -e "${BLUE}=== Backup & Restore ===${NC}"
    echo -e "1) Backup All Settings"
    echo -e "2) Restore From Backup"
    echo -e "3) Schedule Backup"
    echo -e "4) Auto-Backup Settings"
    echo -e "5) View Backup History"
    echo -e "6) Clean Old Backups"
    echo -e "0) Back"
}

# Main Loop
while true; do
    show_main_menu
    read -p "Select option: " main_choice
    case $main_choice in
        1) source /usr/local/bin/ssh-manager.sh ;;
        2) source /usr/local/bin/xray-manager.sh ;;
        3) source /usr/local/bin/openvpn-manager.sh ;;
        4) source /usr/local/bin/l2tp-manager.sh ;;
        5) source /usr/local/bin/service-manager.sh ;;
        6) source /usr/local/bin/system-tools.sh ;;
        7) source /usr/local/bin/security-center.sh ;;
        8) source /usr/local/bin/backup-manager.sh ;;
        0) clear; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -p "Press enter to continue..."
done 