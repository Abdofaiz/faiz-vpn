#!/bin/bash
# Telegram Bot Manager Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Bot Configuration
BOT_CONFIG="/root/bot_config.json"
API_PORT=8069

# Function to setup bot
setup_bot() {
    clear
    echo -e "${BLUE}=== Telegram Bot Setup ===${NC}"
    read -p "Bot Token: " bot_token
    read -p "Admin User ID: " admin_id
    
    # Save bot config
    cat > $BOT_CONFIG <<EOF
{
    "bot_token": "$bot_token",
    "admin_id": "$admin_id",
    "allowed_users": ["$admin_id"],
    "servers": [{
        "name": "Main Server",
        "ip": "$(curl -s ifconfig.me)",
        "api_key": "$(openssl rand -hex 32)"
    }]
}
EOF

    # Create bot service
    cat > /etc/systemd/system/vps-bot.service <<EOF
[Unit]
Description=VPS Management Bot
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/bin/vps-bot.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    # Create bot script
    cat > /usr/local/bin/vps-bot.py <<EOF
#!/usr/bin/python3
import telebot
import json
import requests
import os
import subprocess
from datetime import datetime

# Load config
with open('$BOT_CONFIG', 'r') as f:
    config = json.load(f)

bot = telebot.TeleBot(config['bot_token'])

def check_auth(user_id):
    return str(user_id) in config['allowed_users']

@bot.message_handler(commands=['start'])
def send_welcome(message):
    if check_auth(message.from_user.id):
        bot.reply_to(message, "Welcome to VPS Manager Bot!\nUse /help to see available commands")
    else:
        bot.reply_to(message, "Unauthorized access")

@bot.message_handler(commands=['help'])
def send_help(message):
    if check_auth(message.from_user.id):
        help_text = """
Available commands:
/adduser type username password duration - Create new user
/deluser type username - Delete user
/extend username days - Extend user duration
/check username - Check user status
/quota username - Check user quota
/lock username - Lock user account
/unlock username - Unlock user account
/list type - List all users
/status - Show server status
/backup - Create backup
/servers - List servers
"""
        bot.reply_to(message, help_text)

@bot.message_handler(commands=['adduser'])
def add_user(message):
    if check_auth(message.from_user.id):
        try:
            _, type, user, password, duration = message.text.split()
            result = requests.post(f'http://localhost:{API_PORT}/user/add', 
                json={'type': type, 'username': user, 'password': password, 'duration': duration})
            bot.reply_to(message, result.json()['message'])
        except:
            bot.reply_to(message, "Format: /adduser type username password duration")

@bot.message_handler(commands=['check'])
def check_user(message):
    if check_auth(message.from_user.id):
        try:
            _, username = message.text.split()
            result = requests.get(f'http://localhost:{API_PORT}/user/status/{username}')
            data = result.json()
            response = f"User: {username}\n"
            response += f"Status: {data['status']}\n"
            response += f"Quota: {data['quota_used']}/{data['quota_limit']} GB\n"
            response += f"Logins: {data['current_logins']}\n"
            response += f"Expires: {data['expiry']}"
            bot.reply_to(message, response)
        except:
            bot.reply_to(message, "Format: /check username")

@bot.message_handler(commands=['backup'])
def create_backup(message):
    if str(message.from_user.id) == config['admin_id']:
        backup_file = f"/root/backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.tar.gz"
        os.system(f"tar -czf {backup_file} /root/*_users.txt /root/user_quota.txt /usr/local/etc/xray/config.json")
        bot.send_document(message.chat.id, open(backup_file, 'rb'))
        os.remove(backup_file)

bot.polling()
EOF

    # Install requirements
    pip3 install pyTelegramBotAPI requests

    # Start bot service
    systemctl enable vps-bot
    systemctl start vps-bot
    
    echo -e "${GREEN}Bot setup completed!${NC}"
}

# Function to manage allowed users
manage_users() {
    clear
    echo -e "${BLUE}=== Manage Bot Users ===${NC}"
    echo -e "1) Add User"
    echo -e "2) Remove User"
    echo -e "3) List Users"
    echo -e "0) Back"
    
    read -p "Select option: " choice
    case $choice in
        1)
            read -p "Enter Telegram User ID: " user_id
            jq --arg id "$user_id" '.allowed_users += [$id]' $BOT_CONFIG > /tmp/tmp.json
            mv /tmp/tmp.json $BOT_CONFIG
            systemctl restart vps-bot
            echo -e "${GREEN}User added${NC}"
            ;;
        2)
            read -p "Enter Telegram User ID: " user_id
            jq --arg id "$user_id" '.allowed_users -= [$id]' $BOT_CONFIG > /tmp/tmp.json
            mv /tmp/tmp.json $BOT_CONFIG
            systemctl restart vps-bot
            echo -e "${GREEN}User removed${NC}"
            ;;
        3)
            echo -e "${YELLOW}Allowed Users:${NC}"
            jq '.allowed_users[]' $BOT_CONFIG
            ;;
    esac
}

# Function to manage servers
manage_servers() {
    clear
    echo -e "${BLUE}=== Manage Servers ===${NC}"
    echo -e "1) Add Server"
    echo -e "2) Remove Server"
    echo -e "3) List Servers"
    echo -e "0) Back"
    
    read -p "Select option: " choice
    case $choice in
        1)
            read -p "Server Name: " name
            read -p "Server IP: " ip
            api_key=$(openssl rand -hex 32)
            jq --arg name "$name" --arg ip "$ip" --arg key "$api_key" \
                '.servers += [{"name": $name, "ip": $ip, "api_key": $key}]' $BOT_CONFIG > /tmp/tmp.json
            mv /tmp/tmp.json $BOT_CONFIG
            echo -e "${GREEN}Server added${NC}"
            ;;
        2)
            read -p "Server Name: " name
            jq --arg name "$name" '.servers |= map(select(.name != $name))' $BOT_CONFIG > /tmp/tmp.json
            mv /tmp/tmp.json $BOT_CONFIG
            echo -e "${GREEN}Server removed${NC}"
            ;;
        3)
            echo -e "${YELLOW}Servers:${NC}"
            jq '.servers[]' $BOT_CONFIG
            ;;
    esac
}

# Main Menu
while true; do
    clear
    echo -e "${BLUE}=== Telegram Bot Manager ===${NC}"
    echo -e "1) Setup Bot"
    echo -e "2) Manage Bot Users"
    echo -e "3) Manage Servers"
    echo -e "4) Show Bot Status"
    echo -e "5) Restart Bot"
    echo -e "0) Back to Main Menu"
    
    read -p "Select option: " option
    case $option in
        1) setup_bot ;;
        2) manage_users ;;
        3) manage_servers ;;
        4) systemctl status vps-bot ;;
        5) systemctl restart vps-bot ;;
        0) break ;;
    esac
    read -p "Press enter to continue..."
done 