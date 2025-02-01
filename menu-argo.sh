#!/bin/bash
# Colors and banner code...

echo -e " ${GREEN}1)${NC} Create Argo SSH Tunnel"
echo -e " ${GREEN}2)${NC} Create Argo XRAY Tunnel"
echo -e " ${GREEN}3)${NC} Delete Argo Tunnel"
echo -e " ${GREEN}4)${NC} View Argo Status"
echo -e " ${GREEN}5)${NC} Restart Argo Service"
echo -e " ${RED}0)${NC} Back to Main Menu"

case $opt in
    1) clear ; add-argo-ssh ;;
    2) clear ; add-argo-xray ;;
    3) clear ; del-argo ;;
    4) clear ; cek-argo ;;
    5) clear ; restart-argo ;;
    0) clear ; menu ;;
    *) clear ; menu-argo ;;
esac 