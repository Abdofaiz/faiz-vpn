#!/bin/bash
# Advanced Account Manager Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Database files
SSH_DB="/root/ssh_users.txt"
XRAY_DB="/root/xray_users.txt"
QUOTA_DB="/root/user_quota.txt"
BANNED_DB="/root/banned_users.txt"

# Quota and limit settings
DEFAULT_QUOTA=10 # GB
MAX_LOGIN=2

# Auto-ban settings
MAX_FAILS=3
BAN_TIME=3600 # 1 hour

# Function to check and create quota file
check_quota_file() {
    if [ ! -f "$QUOTA_DB" ]; then
        echo "username quota_limit quota_used last_reset" > "$QUOTA_DB"
    fi
}

# Function to update user quota
update_quota() {
    local user=$1
    local bytes=$2
    
    check_quota_file
    
    # Get current quota usage
    current=$(grep "^$user " "$QUOTA_DB" | awk '{print $3}')
    if [ -z "$current" ]; then
        echo "$user $DEFAULT_QUOTA 0 $(date +%s)" >> "$QUOTA_DB"
        current=0
    fi
    
    # Update quota
    new_usage=$(($current + $bytes))
    sed -i "/^$user / s/[0-9]\+ [0-9]\+/$DEFAULT_QUOTA $new_usage/" "$QUOTA_DB"
    
    # Check if exceeded
    if [ $new_usage -gt $(($DEFAULT_QUOTA * 1024 * 1024 * 1024)) ]; then
        lock_account "$user" "Quota exceeded"
    fi
}

# Function to lock account
lock_account() {
    local user=$1
    local reason=$2
    
    # Lock SSH account
    passwd -l "$user" 2>/dev/null
    
    # Lock XRAY account by removing from config
    if grep -q "^$user " "$XRAY_DB"; then
        jq --arg user "$user" 'walk(if type == "object" and .clients then .clients |= map(select(.email != $user)) else . end)' /usr/local/etc/xray/config.json > /tmp/tmp.json
        mv /tmp/tmp.json /usr/local/etc/xray/config.json
        systemctl restart xray
    fi
    
    # Add to banned list
    echo "$user $reason $(date +%s)" >> "$BANNED_DB"
    
    echo -e "${RED}Account $user locked: $reason${NC}"
}

# Function to unlock account
unlock_account() {
    local user=$1
    
    # Unlock SSH account
    passwd -u "$user" 2>/dev/null
    
    # Restore XRAY account if exists
    if grep -q "^$user " "$XRAY_DB"; then
        local uuid=$(grep "^$user " "$XRAY_DB" | awk '{print $2}')
        jq --arg user "$user" --arg uuid "$uuid" '.inbounds[0].settings.clients += [{"id": $uuid, "email": $user}]' /usr/local/etc/xray/config.json > /tmp/tmp.json
        mv /tmp/tmp.json /usr/local/etc/xray/config.json
        systemctl restart xray
    fi
    
    # Remove from banned list
    sed -i "/^$user /d" "$BANNED_DB"
    
    echo -e "${GREEN}Account $user unlocked${NC}"
}

# Function to check login status
check_login() {
    local user=$1
    local type=$2 # ssh or xray
    
    case $type in
        ssh)
            who | grep "^$user " | wc -l
            ;;
        xray)
            netstat -anp | grep ESTABLISHED | grep xray | grep -i "$user" | wc -l
            ;;
    esac
}

# Function to change UUID/Password
change_credentials() {
    local user=$1
    local type=$2
    
    case $type in
        ssh)
            read -p "New password: " new_pass
            echo "$user:$new_pass" | chpasswd
            sed -i "/^$user / s/ [^ ]\+/ $new_pass/" "$SSH_DB"
            ;;
        xray)
            new_uuid=$(cat /proc/sys/kernel/random/uuid)
            jq --arg user "$user" --arg uuid "$new_uuid" 'walk(if type == "object" and .clients then .clients |= map(if .email == $user then .id = $uuid else . end) else . end)' /usr/local/etc/xray/config.json > /tmp/tmp.json
            mv /tmp/tmp.json /usr/local/etc/xray/config.json
            sed -i "/^$user / s/ [^ ]\+/ $new_uuid/" "$XRAY_DB"
            systemctl restart xray
            ;;
    esac
}

# Function to change domain/port
change_server_config() {
    clear
    echo -e "${BLUE}=== Server Configuration ===${NC}"
    echo -e "1) Change Domain"
    echo -e "2) Change SSH Port"
    echo -e "3) Change XRAY Port"
    echo -e "4) Add Alternative Port"
    echo -e "0) Back"
    
    read -p "Select option: " choice
    case $choice in
        1)
            read -p "Enter new domain: " new_domain
            # Update Nginx config
            sed -i "s/server_name .*/server_name $new_domain;/" /etc/nginx/conf.d/xray.conf
            # Update XRAY config
            jq --arg domain "$new_domain" '.inbounds[].streamSettings.tlsSettings.serverName = $domain' /usr/local/etc/xray/config.json > /tmp/tmp.json
            mv /tmp/tmp.json /usr/local/etc/xray/config.json
            # Restart services
            systemctl restart nginx xray
            ;;
        2)
            read -p "Enter new SSH port: " new_port
            sed -i "s/^Port .*/Port $new_port/" /etc/ssh/sshd_config
            systemctl restart ssh
            ;;
        3)
            read -p "Enter new XRAY port: " new_port
            jq --arg port "$new_port" '.inbounds[0].port = $port' /usr/local/etc/xray/config.json > /tmp/tmp.json
            mv /tmp/tmp.json /usr/local/etc/xray/config.json
            systemctl restart xray
            ;;
        4)
            read -p "Enter alternative port: " alt_port
            # Add to both SSH and XRAY
            echo "Port $alt_port" >> /etc/ssh/sshd_config
            jq --arg port "$alt_port" '.inbounds += [.inbounds[0] | .port = $port]' /usr/local/etc/xray/config.json > /tmp/tmp.json
            mv /tmp/tmp.json /usr/local/etc/xray/config.json
            systemctl restart ssh xray
            ;;
    esac
}

# Main Menu
while true; do
    clear
    echo -e "${BLUE}=== Account Manager ===${NC}"
    echo -e "1) Lock Account"
    echo -e "2) Unlock Account"
    echo -e "3) Set Account Quota"
    echo -e "4) Check User Login"
    echo -e "5) Change Credentials"
    echo -e "6) Server Configuration"
    echo -e "7) Show Banned Users"
    echo -e "8) Show Quota Usage"
    echo -e "0) Back to Main Menu"
    
    read -p "Select option: " option
    case $option in
        1)
            read -p "Username: " user
            read -p "Reason: " reason
            lock_account "$user" "$reason"
            ;;
        2)
            read -p "Username: " user
            unlock_account "$user"
            ;;
        3)
            read -p "Username: " user
            read -p "Quota (GB): " quota
            sed -i "/^$user / s/[0-9]\+ [0-9]\+/$quota 0/" "$QUOTA_DB"
            ;;
        4)
            read -p "Username: " user
            echo -e "SSH Logins: $(check_login $user ssh)"
            echo -e "XRAY Logins: $(check_login $user xray)"
            ;;
        5)
            read -p "Username: " user
            read -p "Type (ssh/xray): " type
            change_credentials "$user" "$type"
            ;;
        6)
            change_server_config
            ;;
        7)
            echo -e "${YELLOW}Banned Users:${NC}"
            cat "$BANNED_DB"
            ;;
        8)
            echo -e "${YELLOW}Quota Usage:${NC}"
            cat "$QUOTA_DB"
            ;;
        0) break ;;
    esac
    read -p "Press enter to continue..."
done 