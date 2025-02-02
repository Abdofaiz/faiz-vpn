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

# Function to create user
create_user() {
    local username="$1"
    local password="$2"
    local duration="$3"
    local type="$4"

    case $type in
        "ssh")
            /usr/local/vpn-script/ssh/add-ssh.sh "$username" "$password" "$duration"
            ;;
        "vmess")
            /usr/local/vpn-script/xray/add-ws.sh "$username" "$duration"
            ;;
        "vless")
            /usr/local/vpn-script/xray/add-grpc.sh "$username" "$duration"
            ;;
    esac

    # Send notification to Telegram
    message="✅ New $type user created\n"
    message+="Username: $username\n"
    message+="Duration: $duration days"
    
    curl -s "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d "chat_id=$ADMIN_ID" \
        -d "text=$message" \
        -d "parse_mode=HTML"
}

# Function to delete user
delete_user() {
    local username="$1"
    local type="$2"

    case $type in
        "ssh")
            /usr/local/vpn-script/ssh/del-ssh.sh "$username"
            ;;
        "xray")
            /usr/local/vpn-script/xray/del-user.sh "$username"
            ;;
    esac

    # Send notification
    message="❌ $type user deleted: $username"
    curl -s "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d "chat_id=$ADMIN_ID" \
        -d "text=$message"
} 