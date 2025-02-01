#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
BOT_TOKEN=$(cat /etc/bot/.token)
ADMIN_ID=$(cat /etc/bot/.admin)
LOG_FILE="/var/log/bot/activity.log"

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}             ${CYAN}BOT MONITORING${NC}                      ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Menu Options
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}Monitoring Options${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} View Bot Status"
echo -e " ${GREEN}2)${NC} View Activity Logs"
echo -e " ${GREEN}3)${NC} Configure Alerts"
echo -e " ${GREEN}4)${NC} Test Notifications"
echo -e " ${GREEN}5)${NC} Clear Logs"
echo -e " ${RED}0)${NC} Back to Bot Menu"
echo -e ""
echo -ne "Select an option [0-5]: "
read opt

case $opt in
    1)
        echo -e "\n${CYAN}Bot Status:${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        # Check bot connection
        if response=$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getMe"); then
            bot_name=$(echo $response | jq -r '.result.username')
            echo -e "Bot Name    : ${GREEN}@$bot_name${NC}"
            echo -e "Status      : ${GREEN}Online${NC}"
            
            # Get bot statistics
            updates=$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getUpdates" | jq '.result | length')
            echo -e "Updates     : ${YELLOW}$updates${NC}"
            
            # Check webhook status
            webhook=$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getWebhookInfo" | jq -r '.result.url')
            if [ "$webhook" != "" ]; then
                echo -e "Webhook     : ${GREEN}Configured${NC}"
                echo -e "URL         : ${BLUE}$webhook${NC}"
            else
                echo -e "Webhook     : ${RED}Not configured${NC}"
            fi
        else
            echo -e "Status      : ${RED}Offline${NC}"
        fi
        ;;
        
    2)
        echo -e "\n${CYAN}Recent Activity Logs:${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        if [ -f "$LOG_FILE" ]; then
            tail -n 20 "$LOG_FILE" | while read line; do
                echo -e "${GREEN}$line${NC}"
            done
        else
            echo -e "${RED}No logs found${NC}"
        fi
        ;;
        
    3)
        echo -e "\n${CYAN}Alert Configuration:${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "1) Enable status alerts"
        echo -e "2) Enable error alerts"
        echo -e "3) Enable user alerts"
        echo -ne "\nSelect alert type [1-3]: "
        read alert_type
        
        case $alert_type in
            1)
                echo "*/30 * * * * /usr/local/bin/check-bot-status.sh" | crontab -
                echo -e "${GREEN}Status alerts enabled${NC}"
                ;;
            2)
                echo "*/15 * * * * /usr/local/bin/check-bot-errors.sh" | crontab -
                echo -e "${GREEN}Error alerts enabled${NC}"
                ;;
            3)
                echo "0 * * * * /usr/local/bin/check-bot-users.sh" | crontab -
                echo -e "${GREEN}User alerts enabled${NC}"
                ;;
        esac
        ;;
        
    4)
        echo -e "\n${CYAN}Sending test notification...${NC}"
        curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
            -d "chat_id=$ADMIN_ID" \
            -d "text=🔔 Test notification from Bot Monitor"
        echo -e "${GREEN}Test notification sent${NC}"
        ;;
        
    5)
        echo -ne "\n${YELLOW}Are you sure you want to clear logs? [y/N]: ${NC}"
        read confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            > "$LOG_FILE"
            echo -e "${GREEN}Logs cleared${NC}"
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