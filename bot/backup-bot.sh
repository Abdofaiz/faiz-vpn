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

# Config paths
BOT_CONFIG="/etc/bot/.config"
BACKUP_DIR="/etc/bot/backups"
TELEGRAM_TOKEN=$(cat "$BOT_CONFIG/token")
ADMIN_ID=$(cat "$BOT_CONFIG/admin_id")

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}             ${CYAN}BACKUP VIA TELEGRAM${NC}                  ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Create backup
echo -e "Creating backup..."
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="backup_$DATE.tar.gz"

tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
    /etc/ssh/.ssh.db \
    /etc/xray/config.json \
    /etc/bot/.config \
    /etc/bot/registered_ips.db

# Send to Telegram
echo -e "Sending backup to Telegram..."
curl -F document=@"$BACKUP_DIR/$BACKUP_FILE" \
    "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument" \
    -F chat_id="$ADMIN_ID" \
    -F caption="🔒 Backup created on $DATE"

echo -e "${GREEN}Backup completed and sent to Telegram${NC}" 