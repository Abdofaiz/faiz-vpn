#!/bin/bash
# L2TP/IPSec Manager Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create L2TP User
create_user() {
    clear
    echo -e "${BLUE}=== Create L2TP User ===${NC}"
    read -p "Username: " user
    read -p "Password: " pass
    read -p "Duration (days): " duration
    
    # Calculate expiry
    exp_date=$(date -d "+${duration} days" +"%Y-%m-%d")
    
    # Add to chap-secrets
    echo "$user l2tpd $pass *" >> /etc/ppp/chap-secrets
    
    # Save user info
    echo "$user $pass $exp_date" >> /root/l2tp_users.txt
    
    # Get PSK and Server IP
    PSK=$(grep "PSK" /etc/ipsec.secrets | cut -d'"' -f2)
    SERVER_IP=$(curl -s ifconfig.me)
    
    # Generate client config
    mkdir -p /home/$user/l2tp
    cat > /home/$user/l2tp/config.txt <<EOF
L2TP/IPSec Configuration:
========================
Server IP: $SERVER_IP
PSK: $PSK
Username: $user
Password: $pass
Expires: $exp_date

For iOS/macOS:
1. Go to Network Settings
2. Add VPN Configuration
3. Type: L2TP
4. Server: $SERVER_IP
5. Account: $user
6. Password: $pass
7. Secret: $PSK

For Android:
1. Go to Settings > Network & Internet > VPN
2. Add VPN Profile
3. Type: L2TP/IPSec PSK
4. Server: $SERVER_IP
5. PSK: $PSK
6. Username: $user
7. Password: $pass
EOF
    
    echo -e "${GREEN}User created successfully!${NC}"
    echo -e "Username: $user"
    echo -e "Password: $pass"
    echo -e "PSK: $PSK"
    echo -e "Expires: $exp_date"
    echo -e "Config saved in: /home/$user/l2tp/config.txt"
}

# Delete L2TP User
delete_user() {
    clear
    echo -e "${BLUE}=== Delete L2TP User ===${NC}"
    read -p "Username to delete: " user
    
    # Remove from chap-secrets
    sed -i "/^$user l2tpd/d" /etc/ppp/chap-secrets
    
    # Remove from database
    sed -i "/^$user /d" /root/l2tp_users.txt
    
    # Remove user directory
    rm -rf /home/$user
    
    echo -e "${GREEN}User $user deleted successfully${NC}"
}

# Extend User
extend_user() {
    clear
    echo -e "${BLUE}=== Extend L2TP User ===${NC}"
    read -p "Username: " user
    read -p "Add days: " add_days
    
    # Check if user exists
    if grep -q "^$user " /root/l2tp_users.txt; then
        # Get current line
        curr_line=$(grep "^$user " /root/l2tp_users.txt)
        curr_exp=$(echo $curr_line | awk '{print $3}')
        
        # Calculate new expiry
        new_exp=$(date -d "$curr_exp +$add_days days" +"%Y-%m-%d")
        
        # Update database
        sed -i "s/$curr_exp/$new_exp/" /root/l2tp_users.txt
        
        echo -e "${GREEN}Expiry date extended to $new_exp${NC}"
    else
        echo -e "${RED}User $user not found${NC}"
    fi
}

# View Users
view_users() {
    clear
    echo -e "${BLUE}=== L2TP Users List ===${NC}"
    echo -e "Username\tExpiry Date\tStatus"
    echo -e "========\t===========\t======"
    
    while IFS=' ' read -r user pass exp; do
        if [ ! -z "$user" ]; then
            today=$(date +%s)
            expiry=$(date -d "$exp" +%s)
            
            if [ $expiry -gt $today ]; then
                status="${GREEN}Active${NC}"
            else
                status="${RED}Expired${NC}"
            fi
            
            echo -e "$user\t$exp\t$status"
        fi
    done < /root/l2tp_users.txt
}

# Monitor Users
monitor_users() {
    clear
    echo -e "${BLUE}=== Active L2TP Connections ===${NC}"
    echo -e "Username\tIP Address\tConnected Since"
    echo -e "========\t==========\t==============="
    
    # Get active PPP sessions
    netstat -anp | grep "xl2tpd" | grep "ESTABLISHED" | while read line; do
        pid=$(echo $line | awk '{print $7}' | cut -d'/' -f1)
        if [ ! -z "$pid" ]; then
            user=$(ps -p $pid -o args= | grep -oP 'user \K[^ ]+')
            ip=$(echo $line | awk '{print $5}')
            since=$(ps -o etime= -p $pid)
            echo -e "$user\t$ip\t$since"
        fi
    done
}

# Change PSK
change_psk() {
    clear
    echo -e "${BLUE}=== Change IPSec PSK ===${NC}"
    read -p "Enter new PSK: " new_psk
    
    # Update PSK in ipsec.secrets
    sed -i "s/PSK.*/PSK \"$new_psk\"/" /etc/ipsec.secrets
    
    # Restart services
    systemctl restart strongswan
    systemctl restart xl2tpd
    
    echo -e "${GREEN}PSK updated successfully${NC}"
    echo -e "New PSK: $new_psk"
}

# Main Menu
while true; do
    clear
    echo -e "${BLUE}=== L2TP/IPSec Manager ===${NC}"
    echo -e "1) Create User"
    echo -e "2) Delete User"
    echo -e "3) Extend User"
    echo -e "4) View Users"
    echo -e "5) Monitor Users"
    echo -e "6) Change PSK"
    echo -e "7) Show IPSec Status"
    echo -e "0) Back to Main Menu"
    
    read -p "Select option: " option
    case $option in
        1) create_user ;;
        2) delete_user ;;
        3) extend_user ;;
        4) view_users ;;
        5) monitor_users ;;
        6) change_psk ;;
        7) ipsec status ;;
        0) break ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -p "Press enter to continue..."
done 