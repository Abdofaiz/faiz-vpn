#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Config paths
BOT_CONFIG="/etc/bot/.config"
TELEGRAM_TOKEN=$(cat "$BOT_CONFIG/token")
ADMIN_ID=$(cat "$BOT_CONFIG/admin_id")

# Generate daily report
generate_report() {
    local report="📊 Daily VPN Report\n\n"
    
    # System info
    report+="💻 System Status:\n"
    report+="CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%\n"
    report+="Memory Usage: $(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}')\n"
    report+="Disk Usage: $(df -h / | awk 'NR==2{print $5}')\n\n"
    
    # Active users
    report+="👥 Active Users:\n"
    report+="SSH: $(grep -c '^###' /etc/ssh/.ssh.db)\n"
    report+="XRAY: $(grep -c '^###' /etc/xray/config.json)\n\n"
    
    # Bandwidth usage
    local rx_bytes=$(cat /sys/class/net/eth0/statistics/rx_bytes)
    local tx_bytes=$(cat /sys/class/net/eth0/statistics/tx_bytes)
    report+="📈 Bandwidth Usage:\n"
    report+="Download: $(echo "scale=2; $rx_bytes/1024/1024/1024" | bc) GB\n"
    report+="Upload: $(echo "scale=2; $tx_bytes/1024/1024/1024" | bc) GB\n"
    
    # Send report
    curl -s "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d "chat_id=$ADMIN_ID" \
        -d "text=$report" \
        -d "parse_mode=HTML"
}

# Add to crontab for daily reports
# 0 0 * * * /usr/local/vpn-script/bot/auto-report.sh 