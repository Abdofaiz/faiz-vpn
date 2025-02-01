#!/bin/bash
# Colors and banner code...

echo -e " ${GREEN}1)${NC} Backup via Telegram Bot"
echo -e " ${GREEN}2)${NC} Restore from Backup"
echo -e " ${GREEN}3)${NC} Auto Backup Settings"
echo -e " ${GREEN}4)${NC} View Backup History"
echo -e " ${RED}0)${NC} Back to Main Menu"

case $opt in
    1) clear ; backup-telegram ;;
    2) clear ; restore-backup ;;
    3) clear ; autobackup-settings ;;
    4) clear ; backup-history ;;
    0) clear ; menu ;;
    *) clear ; menu-backup ;;
esac 