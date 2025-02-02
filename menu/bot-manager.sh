#!/bin/bash
# Telegram Bot Manager Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check root
if [ "${EUID}" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# Config file
BOT_CONFIG="/etc/xray/bot.conf"

clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}     TELEGRAM BOT MANAGER     ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e ""
echo -e "1) Start Bot"
echo -e "2) Stop Bot"
echo -e "3) Set Bot Token"
echo -e "4) Set Admin ID"
echo -e "5) Check Bot Status"
echo -e "6) Exit"
echo -e ""
echo -e "${BLUE}=============================${NC}"
read -p "Select menu : " menu

case $menu in
    1)
        systemctl start xray-bot
        echo -e "${GREEN}Bot started${NC}"
        ;;
    2)
        systemctl stop xray-bot
        echo -e "${RED}Bot stopped${NC}"
        ;;
    3)
        read -p "Input bot token : " token
        echo "BOT_TOKEN=$token" > $BOT_CONFIG
        systemctl restart xray-bot
        echo -e "${GREEN}Bot token updated${NC}"
        ;;
    4)
        read -p "Input admin ID : " admin_id
        echo "ADMIN_ID=$admin_id" >> $BOT_CONFIG
        systemctl restart xray-bot
        echo -e "${GREEN}Admin ID updated${NC}"
        ;;
    5)
        status=$(systemctl status xray-bot | grep Active | awk '{print $2}')
        if [ "$status" == "active" ]; then
            echo -e "Bot Status: ${GREEN}Running${NC}"
        else
            echo -e "Bot Status: ${RED}Not Running${NC}"
        fi
        ;;
    6)
        exit
        ;;
    *)
        echo -e "${RED}Invalid menu${NC}"
        ;;
esac 