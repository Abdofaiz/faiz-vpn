#!/bin/bash
# Colors and banner code...

echo -e " ${GREEN}1)${NC} Ban SSH Account"
echo -e " ${GREEN}2)${NC} Ban XRAY Account"
echo -e " ${GREEN}3)${NC} Unban SSH Account"
echo -e " ${GREEN}4)${NC} Unban XRAY Account"
echo -e " ${GREEN}5)${NC} Lock XRAY Account"
echo -e " ${GREEN}6)${NC} Lock SSH Account"
echo -e " ${GREEN}7)${NC} Unlock XRAY Account"
echo -e " ${GREEN}8)${NC} Unlock SSH Account"
echo -e " ${GREEN}9)${NC} View Banned Users"
echo -e " ${GREEN}10)${NC} View Locked Users"
echo -e " ${RED}0)${NC} Back to Main Menu"

case $opt in
    1) clear ; ban-ssh ;;
    2) clear ; ban-xray ;;
    3) clear ; unban-ssh ;;
    4) clear ; unban-xray ;;
    5) clear ; lock-xray ;;
    6) clear ; lock-ssh ;;
    7) clear ; unlock-xray ;;
    8) clear ; unlock-ssh ;;
    9) clear ; view-banned ;;
    10) clear ; view-locked ;;
    0) clear ; menu ;;
    *) clear ; menu-security ;;
esac 