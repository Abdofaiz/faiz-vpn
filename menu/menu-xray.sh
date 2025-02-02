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
echo -e "${CYAN}│${NC}                 ${CYAN}XRAY MENU${NC}                         ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "     ${CYAN}XRAY${NC} : $(grep -c -E "^### " "/etc/xray/config.json") ${GREEN}ACTIVE USERS${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Service Status
xray_service=$(systemctl is-active xray)
nginx_service=$(systemctl is-active nginx)
haproxy_service=$(systemctl is-active haproxy)

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}Service Status${NC} "
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  XRAY        : $(if [[ $xray_service == "active" ]]; then echo -e "${GREEN}Running${NC}"; else echo -e "${RED}Not Running${NC}"; fi)"
echo -e "  Nginx       : $(if [[ $nginx_service == "active" ]]; then echo -e "${GREEN}Running${NC}"; else echo -e "${RED}Not Running${NC}"; fi)"
echo -e "  HAProxy     : $(if [[ $haproxy_service == "active" ]]; then echo -e "${GREEN}Running${NC}"; else echo -e "${RED}Not Running${NC}"; fi)"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

# Protocol Information
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}XRAY Protocols & Ports${NC} "
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${YELLOW}VMESS${NC}"
echo -e "  ∟ Websocket TLS        : 443"
echo -e "  ∟ Websocket Non-TLS    : 80"
echo -e "  ∟ gRPC                 : 443"
echo -e "  ∟ TCP HTTP             : 443"
echo -e ""
echo -e "  ${YELLOW}VLESS${NC}"
echo -e "  ∟ Websocket TLS        : 443"
echo -e "  ∟ Websocket Non-TLS    : 80"
echo -e "  ∟ gRPC                 : 443"
echo -e "  ∟ XTLS                 : 443"
echo -e ""
echo -e "  ${YELLOW}TROJAN${NC}"
echo -e "  ∟ Websocket TLS        : 443"
echo -e "  ∟ gRPC                 : 443"
echo -e "  ∟ TCP                  : 443"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

# Menu Options
echo -e " ${GREEN}1)${NC} VMESS Menu"
echo -e " ${GREEN}2)${NC} VLESS Menu"
echo -e " ${GREEN}3)${NC} TROJAN Menu"
echo -e " ${GREEN}4)${NC} Create Trial Account"
echo -e " ${GREEN}5)${NC} Check User Login"
echo -e " ${GREEN}6)${NC} List All Members"
echo -e " ${GREEN}7)${NC} Renew Certificate"
echo -e " ${GREEN}8)${NC} Edit Port"
echo -e " ${GREEN}9)${NC} Check Configuration"
echo -e " ${GREEN}10)${NC} Restart Services"
echo -e " ${RED}0)${NC} Back to Main Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-10]: "
read opt

case $opt in
    1) clear ; menu-vmess ;;
    2) clear ; menu-vless ;;
    3) clear ; menu-trojan ;;
    4) clear ; trial-xray ;;
    5) clear ; cek-xray ;;
    6) clear ; list-xray ;;
    7) clear ; cert-xray ;;
    8) clear ; port-xray ;;
    9) clear ; config-xray ;;
    10) clear ; restart-xray ;;
    0) clear ; menu ;;
    *) clear ; menu-xray ;;
esac 