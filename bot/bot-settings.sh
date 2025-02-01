#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration files
TOKEN_FILE="/etc/bot/.token"
ADMIN_FILE="/etc/bot/.admin"
CONFIG_FILE="/etc/bot/config.json"

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}               ${CYAN}BOT SETTINGS${NC}                       ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Menu Options
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}Bot Configuration${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Set Bot Token"
echo -e " ${GREEN}2)${NC} Set Admin ID"
echo -e " ${GREEN}3)${NC} Set Welcome Message"
echo -e " ${GREEN}4)${NC} Configure Auto-Response"
echo -e " ${GREEN}5)${NC} View Current Settings"
echo -e " ${GREEN}6)${NC} Test Bot Connection"
echo -e " ${RED}0)${NC} Back to Bot Menu"
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -ne "Select an option [0-6]: "
read opt

case $opt in
    1)
        echo -ne "\nEnter Bot Token: "
        read token
        echo "$token" > $TOKEN_FILE
        echo -e "${GREEN}Bot token has been updated${NC}"
        ;;
    2)
        echo -ne "\nEnter Admin Telegram ID: "
        read admin_id
        echo "$admin_id" > $ADMIN_FILE
        echo -e "${GREEN}Admin ID has been updated${NC}"
        ;;
    3)
        echo -ne "\nEnter Welcome Message: "
        read welcome_msg
        jq --arg msg "$welcome_msg" '.welcome_message = $msg' $CONFIG_FILE > tmp.json && mv tmp.json $CONFIG_FILE
        echo -e "${GREEN}Welcome message has been updated${NC}"
        ;;
    4)
        echo -e "\n${CYAN}Auto-Response Configuration${NC}"
        echo -ne "Enter trigger word: "
        read trigger
        echo -ne "Enter response: "
        read response
        jq --arg t "$trigger" --arg r "$response" '.auto_responses += [{trigger: $t, response: $r}]' $CONFIG_FILE > tmp.json && mv tmp.json $CONFIG_FILE
        echo -e "${GREEN}Auto-response has been added${NC}"
        ;;
    5)
        echo -e "\n${CYAN}Current Settings:${NC}"
        echo -e "Bot Token : $(cat $TOKEN_FILE | cut -c1-10)..."
        echo -e "Admin ID  : $(cat $ADMIN_FILE)"
        echo -e "Welcome   : $(jq -r '.welcome_message' $CONFIG_FILE)"
        echo -e "\nAuto-Responses:"
        jq -r '.auto_responses[] | "Trigger: \(.trigger)\nResponse: \(.response)\n"' $CONFIG_FILE
        ;;
    6)
        echo -e "\n${CYAN}Testing Bot Connection...${NC}"
        token=$(cat $TOKEN_FILE)
        admin_id=$(cat $ADMIN_FILE)
        if response=$(curl -s "https://api.telegram.org/bot$token/getMe"); then
            bot_name=$(echo $response | jq -r '.result.username')
            echo -e "${GREEN}Bot is active: @$bot_name${NC}"
            # Send test message to admin
            curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
                -d "chat_id=$admin_id" \
                -d "text=Bot connection test successful!"
            echo -e "${GREEN}Test message sent to admin${NC}"
        else
            echo -e "${RED}Failed to connect to bot${NC}"
        fi
        ;;
    0)
        menu-bot
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        ;;
esac

echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-bot 