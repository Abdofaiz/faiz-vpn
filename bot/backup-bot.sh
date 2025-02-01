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
DATE=$(date +%Y%m%d_%H%M%S)
TELEGRAM_CONFIG="/etc/bot/.token"
ADMIN_ID=$(cat /etc/bot/.admin)
BOT_TOKEN=$(cat /etc/bot/.token)

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}             ${CYAN}BOT BACKUP SYSTEM${NC}                    ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Create backup directory if not exists
mkdir -p $BACKUP_DIR

# Menu Options
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}Backup Options${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${GREEN}1)${NC} Create Backup"
echo -e " ${GREEN}2)${NC} Restore Backup"
echo -e " ${GREEN}3)${NC} List Backups"
echo -e " ${GREEN}4)${NC} Delete Backup"
echo -e " ${GREEN}5)${NC} Upload Backup to Telegram"
echo -e " ${RED}0)${NC} Back to Bot Menu"
echo -e ""
echo -ne "Select an option [0-5]: "
read opt

case $opt in
    1)
        echo -e "\n${CYAN}Creating backup...${NC}"
        backup_file="bot_backup_${DATE}.tar.gz"
        
        # Create backup
        tar -czf "$BACKUP_DIR/$backup_file" -C $BOT_CONFIG_DIR .
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Backup created successfully: $backup_file${NC}"
            # Send notification to admin
            curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
                -d "chat_id=$ADMIN_ID" \
                -d "text=🔄 New bot backup created: $backup_file"
        else
            echo -e "${RED}Backup creation failed${NC}"
        fi
        ;;
        
    2)
        echo -e "\n${CYAN}Available backups:${NC}"
        ls -1 $BACKUP_DIR | nl
        echo -ne "\nSelect backup to restore (number): "
        read backup_num
        
        backup_file=$(ls -1 $BACKUP_DIR | sed -n "${backup_num}p")
        if [ ! -z "$backup_file" ]; then
            echo -e "${YELLOW}Warning: This will overwrite current settings${NC}"
            echo -ne "Continue? [y/N]: "
            read confirm
            
            if [[ $confirm =~ ^[Yy]$ ]]; then
                tar -xzf "$BACKUP_DIR/$backup_file" -C $BOT_CONFIG_DIR
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}Backup restored successfully${NC}"
                    # Send notification to admin
                    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
                        -d "chat_id=$ADMIN_ID" \
                        -d "text=♻️ Bot backup restored: $backup_file"
                else
                    echo -e "${RED}Restore failed${NC}"
                fi
            fi
        else
            echo -e "${RED}Invalid backup selection${NC}"
        fi
        ;;
        
    3)
        echo -e "\n${CYAN}Available backups:${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        for backup in $BACKUP_DIR/*; do
            if [ -f "$backup" ]; then
                size=$(du -h "$backup" | cut -f1)
                date=$(date -r "$backup" "+%Y-%m-%d %H:%M:%S")
                echo -e "File: ${GREEN}$(basename $backup)${NC}"
                echo -e "Size: ${YELLOW}$size${NC}"
                echo -e "Date: ${BLUE}$date${NC}"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            fi
        done
        ;;
        
    4)
        echo -e "\n${CYAN}Available backups:${NC}"
        ls -1 $BACKUP_DIR | nl
        echo -ne "\nSelect backup to delete (number): "
        read backup_num
        
        backup_file=$(ls -1 $BACKUP_DIR | sed -n "${backup_num}p")
        if [ ! -z "$backup_file" ]; then
            rm "$BACKUP_DIR/$backup_file"
            echo -e "${GREEN}Backup deleted: $backup_file${NC}"
        else
            echo -e "${RED}Invalid backup selection${NC}"
        fi
        ;;
        
    5)
        echo -e "\n${CYAN}Available backups:${NC}"
        ls -1 $BACKUP_DIR | nl
        echo -ne "\nSelect backup to upload (number): "
        read backup_num
        
        backup_file=$(ls -1 $BACKUP_DIR | sed -n "${backup_num}p")
        if [ ! -z "$backup_file" ]; then
            echo -e "${CYAN}Uploading to Telegram...${NC}"
            curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendDocument" \
                -F "chat_id=$ADMIN_ID" \
                -F "document=@$BACKUP_DIR/$backup_file" \
                -F "caption=📦 Bot backup file: $backup_file"
            echo -e "${GREEN}Backup uploaded to Telegram${NC}"
        else
            echo -e "${RED}Invalid backup selection${NC}"
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