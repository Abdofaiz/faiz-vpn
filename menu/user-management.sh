#!/bin/bash
# User Management System

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Create add user function
add_user() {
    clear
    echo -e "${GREEN}=== Add New User ===${NC}"
    read -p "Username : " username
    read -p "Password : " password
    read -p "Duration (days) : " duration

    # Check if user exists
    if id "$username" &>/dev/null; then
        echo -e "${RED}Error: User already exists${NC}"
        return 1
    fi

    # Calculate expiry date
    exp_date=$(date -d "+${duration} days" +"%Y-%m-%d")
    
    # Add system user
    useradd -e "$exp_date" -s /bin/false "$username"
    echo "$username:$password" | chpasswd

    # Add to XRAY VMess
    uuid=$(cat /proc/sys/kernel/random/uuid)
    jq --arg user "$username" --arg uuid "$uuid" \
        '.inbounds[0].settings.clients += [{"id": $uuid, "email": $user}]' \
        /usr/local/etc/xray/config.json > /tmp/xray.tmp && \
        mv /tmp/xray.tmp /usr/local/etc/xray/config.json

    # Add to Trojan-GO
    jq --arg user "$username" --arg pass "$password" \
        '.password += [$pass]' \
        /usr/local/etc/trojan-go/config.json > /tmp/trojan.tmp && \
        mv /tmp/trojan.tmp /usr/local/etc/trojan-go/config.json

    # Restart services
    systemctl restart xray
    systemctl restart trojan-go

    # Save user info
    echo "$username $password $exp_date" >> /root/user_database.txt

    echo -e "${GREEN}User added successfully!${NC}"
    echo -e "Username: $username"
    echo -e "Password: $password"
    echo -e "Expires: $exp_date"
}

# Create delete user function
delete_user() {
    clear
    echo -e "${RED}=== Delete User ===${NC}"
    read -p "Username to delete: " username

    # Check if user exists
    if ! id "$username" &>/dev/null; then
        echo -e "${RED}Error: User does not exist${NC}"
        return 1
    }

    # Delete system user
    userdel -r "$username"

    # Remove from XRAY
    jq --arg user "$username" \
        'del(.inbounds[0].settings.clients[] | select(.email == $user))' \
        /usr/local/etc/xray/config.json > /tmp/xray.tmp && \
        mv /tmp/xray.tmp /usr/local/etc/xray/config.json

    # Remove from user database
    sed -i "/^$username /d" /root/user_database.txt

    # Restart services
    systemctl restart xray
    systemctl restart trojan-go

    echo -e "${GREEN}User deleted successfully!${NC}"
}

# Create list users function
list_users() {
    clear
    echo -e "${GREEN}=== User List ===${NC}"
    echo -e "Username\tExpiry Date\tStatus"
    echo -e "========\t===========\t======"
    
    while read -r user pass exp; do
        today=$(date +%s)
        expiry=$(date -d "$exp" +%s)
        
        if [ $expiry -gt $today ]; then
            status="${GREEN}Active${NC}"
        else
            status="${RED}Expired${NC}"
        fi
        
        echo -e "$user\t$exp\t$status"
    done < /root/user_database.txt
}

# Create check expired users function
check_expired() {
    echo -e "${YELLOW}Checking expired users...${NC}"
    while read -r user pass exp; do
        if [ "$(date -d "$exp" +%s)" -lt "$(date +%s)" ]; then
            echo "Deleting expired user: $user"
            userdel -r "$user"
            sed -i "/^$user /d" /root/user_database.txt
        fi
    done < /root/user_database.txt
    
    systemctl restart xray
    systemctl restart trojan-go
    echo -e "${GREEN}Expired users cleaned up${NC}"
}

# Main menu
while true; do
    clear
    echo -e "${GREEN}=== User Management Menu ===${NC}"
    echo -e "1) Add User"
    echo -e "2) Delete User"
    echo -e "3) List Users"
    echo -e "4) Check Expired Users"
    echo -e "0) Exit"
    read -p "Select option: " choice

    case $choice in
        1) add_user ;;
        2) delete_user ;;
        3) list_users ;;
        4) check_expired ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    
    read -p "Press enter to continue..."
done 