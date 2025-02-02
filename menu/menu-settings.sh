#!/bin/bash
# Colors and banner code...

echo -e " ${GREEN}1)${NC} Change Domain/Host"
echo -e " ${GREEN}2)${NC} Change Port SSH"
echo -e " ${GREEN}3)${NC} Change Port XRAY"
echo -e " ${GREEN}4)${NC} Change UUID XRAY"
echo -e " ${GREEN}5)${NC} Change Password SSH"
echo -e " ${GREEN}6)${NC} Change Bot API Token"
echo -e " ${GREEN}7)${NC} Change Admin ID"
echo -e " ${RED}0)${NC} Back to Main Menu"

case $opt in
    1) clear ; change-domain ;;
    2) clear ; change-port-ssh ;;
    3) clear ; change-port-xray ;;
    4) clear ; change-uuid ;;
    5) clear ; change-pass ;;
    6) clear ; change-bot-token ;;
    7) clear ; change-admin-id ;;
    0) clear ; menu ;;
    *) clear ; menu-settings ;;
esac 