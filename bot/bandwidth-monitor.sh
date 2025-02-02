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

# Get bandwidth usage
get_bandwidth() {
    local interface="eth0"
    local rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes)
    local tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes)
    
    # Convert to GB
    local rx_gb=$(echo "scale=2; $rx_bytes/1024/1024/1024" | bc)
    local tx_gb=$(echo "scale=2; $tx_bytes/1024/1024/1024" | bc)
    
    echo -e "Download: ${GREEN}$rx_gb GB${NC}"
    echo -e "Upload: ${GREEN}$tx_gb GB${NC}"
    
    # Send to Telegram if exceeds threshold
    if (( $(echo "$rx_gb > 100" | bc -l) )); then
        message="⚠️ High bandwidth usage alert!\n"
        message+="Download: $rx_gb GB\n"
        message+="Upload: $tx_gb GB"
        
        curl -s "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
            -d "chat_id=$ADMIN_ID" \
            -d "text=$message" \
            -d "parse_mode=HTML"
    fi
}

# Monitor specific user bandwidth
monitor_user() {
    local username="$1"
    local iptables_data=$(iptables -nvx -L)
    local download=$(echo "$iptables_data" | grep "$username" | awk '{print $2}')
    local upload=$(echo "$iptables_data" | grep "$username" | awk '{print $3}')
    
    echo -e "User: $username"
    echo -e "Download: ${GREEN}$(($download/1024/1024)) MB${NC}"
    echo -e "Upload: ${GREEN}$(($upload/1024/1024)) MB${NC}"
} 