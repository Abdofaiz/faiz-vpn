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

# Show menu
show_menu() {
    clear
    echo -e "${BLUE}=============================${NC}"
    echo -e "${YELLOW}     ACCOUNT MANAGER     ${NC}"
    echo -e "${BLUE}=============================${NC}"
    echo -e ""
    echo -e "${GREEN}1${NC}. Create Account"
    echo -e "${GREEN}2${NC}. Delete Account"
    echo -e "${GREEN}3${NC}. Extend Account"
    echo -e "${GREEN}4${NC}. List Accounts"
    echo -e "${GREEN}5${NC}. Monitor Users"
    echo -e "${GREEN}6${NC}. Manage Quota"
    echo -e "${GREEN}7${NC}. Lock Account"
    echo -e "${GREEN}8${NC}. Unlock Account"
    echo -e "${GREEN}9${NC}. Change Credentials"
    echo -e "${GREEN}10${NC}. Server Configuration"
    echo -e "${GREEN}11${NC}. Show Banned Users"
    echo -e "${GREEN}12${NC}. Show Quota Usage"
    echo -e "${GREEN}0${NC}. Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}=============================${NC}"
}

# Create account
create_account() {
    read -p "Username: " user
    read -p "Password: " pass
    read -p "Duration (days): " duration
    
    exp=$(date -d "+$duration days" +"%Y-%m-%d")
    useradd -e "$exp" -s /bin/false -M $user
    echo "$user:$pass" | chpasswd
    
    echo "$user $pass $exp" >> $SSH_DB
    echo "$user $pass $exp" >> $XRAY_DB
    echo "$user 0 0" >> $QUOTA_DB
    
    echo -e "${GREEN}Account created successfully${NC}"
}

# Delete account
delete_account() {
    read -p "Username to delete: " user
    userdel -f $user
    sed -i "/^$user /d" $SSH_DB
    sed -i "/^$user /d" $XRAY_DB
    sed -i "/^$user /d" $QUOTA_DB
    echo -e "${GREEN}Account deleted successfully${NC}"
}

# Extend account
extend_account() {
    read -p "Username to extend: " user
    read -p "Duration (days): " duration
    
    if grep -q "^$user " $SSH_DB; then
        exp=$(date -d "+$duration days" +"%Y-%m-%d")
        chage -E "$exp" $user
        sed -i "/^$user / s/ [^ ]*$/ $exp/" $SSH_DB
        sed -i "/^$user / s/ [^ ]*$/ $exp/" $XRAY_DB
        echo -e "${GREEN}Account extended successfully${NC}"
    else
        echo -e "${RED}User not found${NC}"
    fi
}

# List accounts
list_accounts() {
    echo -e "${YELLOW}User Accounts:${NC}"
    echo -e "Username | Expiry | Quota Used"
    echo -e "------------------------"
    while IFS=' ' read -r user pass exp; do
        quota=$(grep "^$user " $QUOTA_DB | awk '{print $2}')
        echo -e "$user | $exp | $quota MB"
    done < $SSH_DB
}

# Monitor users
monitor_users() {
    echo -e "${YELLOW}Online Users:${NC}"
    echo -e "------------------------"
    who
    echo -e "\n${YELLOW}Connection History:${NC}"
    last | head -n 10
}

# Manage quota
manage_quota() {
    echo -e "${YELLOW}Quota Management:${NC}"
    echo -e "1. Set Quota"
    echo -e "2. Reset Quota"
    echo -e "3. View Quota"
    read -p "Select option: " choice
    
    case $choice in
        1)
            read -p "Username: " user
            read -p "Quota (MB): " quota
            sed -i "/^$user / s/ [^ ]*$/ $quota/" $QUOTA_DB
            echo -e "${GREEN}Quota set successfully${NC}"
            ;;
        2)
            read -p "Username: " user
            sed -i "/^$user / s/ [^ ]*$/ 0/" $QUOTA_DB
            echo -e "${GREEN}Quota reset successfully${NC}"
            ;;
        3)
            echo -e "${YELLOW}User Quotas:${NC}"
            cat $QUOTA_DB
            ;;
    esac
}

# Main loop
while true; do
    show_menu
    read -p "Select option: " choice
    case $choice in
        1) create_account ;;
        2) delete_account ;;
        3) extend_account ;;
        4) list_accounts ;;
        5) monitor_users ;;
        6) manage_quota ;;
        7)
            read -p "Username: " user
            read -p "Reason: " reason
            lock_account "$user" "$reason"
            ;;
        8)
            read -p "Username: " user
            unlock_account "$user"
            ;;
        9)
            read -p "Username: " user
            read -p "Type (ssh/xray): " type
            change_credentials "$user" "$type"
            ;;
        10)
            change_server_config
            ;;
        11)
            echo -e "${YELLOW}Banned Users:${NC}"
            cat "$BANNED_DB"
            ;;
        12)
            echo -e "${YELLOW}Quota Usage:${NC}"
            cat "$QUOTA_DB"
            ;;
        0) break ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -n 1 -s -r -p "Press any key to continue"
done 