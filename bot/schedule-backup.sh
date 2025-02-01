#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
BACKUP_DIR="/etc/bot/backups"
BOT_CONFIG_DIR="/etc/bot"
CRON_FILE="/etc/cron.d/bot-backup"
BOT_TOKEN=$(cat /etc/bot/.token)
ADMIN_ID=$(cat /etc/bot/.admin)
RETENTION_DAYS=7

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}          ${CYAN}AUTOMATED BACKUP SCHEDULER${NC}               ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Menu Options
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}Schedule Options${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Daily Backup"
echo -e " ${GREEN}2)${NC} Weekly Backup"
echo -e " ${GREEN}3)${NC} Custom Schedule"
echo -e " ${GREEN}4)${NC} View Current Schedule"
echo -e " ${GREEN}5)${NC} Disable Scheduled Backup"
echo -e " ${GREEN}6)${NC} Configure Retention"
echo -e " ${RED}0)${NC} Back to Bot Menu"
echo -e ""
echo -ne "Select an option [0-6]: "
read opt

# Create backup script
create_backup_script() {
    cat > /usr/local/bin/auto-backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/etc/bot/backups"
BOT_CONFIG_DIR="/etc/bot"
DATE=$(date +%Y%m%d_%H%M%S)
BOT_TOKEN=$(cat /etc/bot/.token)
ADMIN_ID=$(cat /etc/bot/.admin)
RETENTION_DAYS=$(cat /etc/bot/.retention 2>/dev/null || echo "7")

# Create backup
backup_file="bot_backup_${DATE}.tar.gz"
tar -czf "$BACKUP_DIR/$backup_file" -C $BOT_CONFIG_DIR .

# Send notification
if [ $? -eq 0 ]; then
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$ADMIN_ID" \
        -d "text=🔄 Automated backup created: $backup_file"
    
    # Cleanup old backups
    find $BACKUP_DIR -name "bot_backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete
else
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$ADMIN_ID" \
        -d "text=⚠️ Automated backup failed!"
fi
EOF
    chmod +x /usr/local/bin/auto-backup.sh
}

case $opt in
    1)
        echo -ne "\nSelect hour for daily backup (0-23): "
        read hour
        if [[ $hour =~ ^[0-9]+$ ]] && [ $hour -ge 0 ] && [ $hour -le 23 ]; then
            create_backup_script
            echo "0 $hour * * * root /usr/local/bin/auto-backup.sh" > $CRON_FILE
            systemctl restart cron
            echo -e "${GREEN}Daily backup scheduled for $hour:00${NC}"
        else
            echo -e "${RED}Invalid hour${NC}"
        fi
        ;;
        
    2)
        echo -ne "\nSelect day of week (0=Sunday - 6=Saturday): "
        read day
        echo -ne "Select hour (0-23): "
        read hour
        if [[ $day =~ ^[0-6]$ ]] && [[ $hour =~ ^[0-9]+$ ]] && [ $hour -ge 0 ] && [ $hour -le 23 ]; then
            create_backup_script
            echo "0 $hour * * $day root /usr/local/bin/auto-backup.sh" > $CRON_FILE
            systemctl restart cron
            echo -e "${GREEN}Weekly backup scheduled for $(date -d "next sunday + $day days" +%A) at $hour:00${NC}"
        else
            echo -e "${RED}Invalid input${NC}"
        fi
        ;;
        
    3)
        echo -ne "\nEnter custom cron schedule (e.g., '0 3 * * *' for 3 AM daily): "
        read schedule
        if [[ $schedule =~ ^[0-9*/-]+" "+[0-9*/-]+" "+[0-9*/-]+" "+[0-9*/-]+" "+[0-9*/-]+$ ]]; then
            create_backup_script
            echo "$schedule root /usr/local/bin/auto-backup.sh" > $CRON_FILE
            systemctl restart cron
            echo -e "${GREEN}Custom backup schedule set${NC}"
        else
            echo -e "${RED}Invalid cron format${NC}"
        fi
        ;;
        
    4)
        echo -e "\n${CYAN}Current Backup Schedule:${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        if [ -f $CRON_FILE ]; then
            cat $CRON_FILE
        else
            echo -e "${YELLOW}No backup schedule configured${NC}"
        fi
        echo -e "\n${CYAN}Retention Period:${NC} ${GREEN}$RETENTION_DAYS days${NC}"
        ;;
        
    5)
        if [ -f $CRON_FILE ]; then
            rm $CRON_FILE
            systemctl restart cron
            echo -e "${GREEN}Scheduled backup disabled${NC}"
        else
            echo -e "${YELLOW}No backup schedule found${NC}"
        fi
        ;;
        
    6)
        echo -ne "\nEnter number of days to keep backups: "
        read days
        if [[ $days =~ ^[0-9]+$ ]] && [ $days -gt 0 ]; then
            echo "$days" > /etc/bot/.retention
            echo -e "${GREEN}Retention period set to $days days${NC}"
        else
            echo -e "${RED}Invalid number of days${NC}"
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