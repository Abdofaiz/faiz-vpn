#!/bin/bash
# SSH & WebSocket Manager

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create SSH User
create_ssh_user() {
    clear
    echo -e "${BLUE}=== Create SSH User ===${NC}"
    read -p "Username: " username
    read -p "Password: " password
    read -p "Duration (days): " duration
    
    # Calculate expiry date
    exp_date=$(date -d "+${duration} days" +"%Y-%m-%d")
    
    # Create user
    useradd -e "$exp_date" -s /bin/false "$username"
    echo "$username:$password" | chpasswd

    # Save user info
    echo "$username $password $exp_date" >> /root/user_database.txt

    # Create user config files
    mkdir -p /home/$username/ws
    cat > /home/$username/ws/config.txt <<EOF
WebSocket Configuration:
=======================
Host: $(curl -s ifconfig.me)
Port: 80/443
Path: /ws
Header:
GET / HTTP/1.1[crlf]
Host: $(curl -s ifconfig.me)[crlf]
Upgrade: websocket[crlf]
Connection: Upgrade[crlf]
[crlf]

SSH Configuration:
================
Host: $(curl -s ifconfig.me)
Port: 22/443

Dropbear Configuration:
=====================
Host: $(curl -s ifconfig.me)
Port: 109/143

Username: $username
Password: $password
Expired: $exp_date
EOF

    echo -e "${GREEN}User created successfully!${NC}"
    echo -e "Username: $username"
    echo -e "Password: $password"
    echo -e "Expires: $exp_date"
    echo -e "Config saved in: /home/$username/ws/config.txt"
}

# Delete SSH User
delete_ssh_user() {
    clear
    echo -e "${BLUE}=== Delete SSH User ===${NC}"
    read -p "Username to delete: " username
    
    if id "$username" &>/dev/null; then
        userdel -r "$username"
        sed -i "/^$username /d" /root/user_database.txt
        echo -e "${GREEN}User $username deleted successfully${NC}"
    else
        echo -e "${RED}User $username not found${NC}"
    fi
}

# Extend User Expiry
extend_user() {
    clear
    echo -e "${BLUE}=== Extend User Expiry ===${NC}"
    read -p "Username: " username
    read -p "Add days: " add_days
    
    if id "$username" &>/dev/null; then
        # Get current expiry
        curr_exp=$(chage -l $username | grep "Account expires" | cut -d: -f2)
        # Calculate new expiry
        new_exp=$(date -d "$curr_exp +$add_days days" +"%Y-%m-%d")
        chage -E "$new_exp" "$username"
        # Update database
        sed -i "s/^$username .* /&$new_exp/" /root/user_database.txt
        echo -e "${GREEN}Expiry date extended to $new_exp${NC}"
    else
        echo -e "${RED}User $username not found${NC}"
    fi
}

# View SSH Users
view_users() {
    clear
    echo -e "${BLUE}=== SSH Users List ===${NC}"
    echo -e "Username\tExpiry Date\tStatus"
    echo -e "========\t===========\t======"
    
    while read -r user pass exp; do
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
    done < /root/user_database.txt
}

# Monitor SSH Users
monitor_users() {
    clear
    echo -e "${BLUE}=== Active SSH Connections ===${NC}"
    echo -e "Username\tIP Address\tConnected Since"
    echo -e "========\t==========\t==============="
    
    data=($(ps aux | grep -i sshd | grep -v grep | awk '{print $2}'))
    for pid in "${data[@]}"; do
        cat /proc/$pid/environ &> /dev/null
        if [ $? -eq 0 ]; then
            user=$(cat /proc/$pid/environ | tr '\0' '\n' | grep '^USER=' | cut -d= -f2)
            if [ ! -z "$user" ]; then
                ip=$(netstat -np | grep $pid | grep -v unix | awk '{print $5}' | cut -d: -f1)
                connected=$(ps -o etime= -p $pid)
                echo -e "$user\t$ip\t$connected"
            fi
        fi
    done
}

# WebSocket Settings
websocket_settings() {
    clear
    echo -e "${BLUE}=== WebSocket Settings ===${NC}"
    echo -e "1) Change WS Port"
    echo -e "2) Change WS Path"
    echo -e "3) Enable SSL"
    echo -e "4) Disable SSL"
    echo -e "5) Show WS Status"
    echo -e "0) Back"
    
    read -p "Select option: " ws_choice
    case $ws_choice in
        1) 
            read -p "Enter new WebSocket port: " ws_port
            sed -i "s/LISTENING_PORT = .*/LISTENING_PORT = $ws_port/" /usr/local/bin/ws-http
            systemctl restart ws-http
            echo -e "${GREEN}WebSocket port updated${NC}"
            ;;
        2)
            read -p "Enter new WebSocket path: " ws_path
            sed -i "s|/ws|$ws_path|g" /usr/local/bin/ws-http
            systemctl restart ws-http
            echo -e "${GREEN}WebSocket path updated${NC}"
            ;;
        3)
            systemctl enable ws-ssl
            systemctl start ws-ssl
            echo -e "${GREEN}SSL WebSocket enabled${NC}"
            ;;
        4)
            systemctl stop ws-ssl
            systemctl disable ws-ssl
            echo -e "${GREEN}SSL WebSocket disabled${NC}"
            ;;
        5)
            echo -e "WebSocket HTTP Status:"
            systemctl status ws-http
            echo -e "\nWebSocket SSL Status:"
            systemctl status ws-ssl
            ;;
        0) return ;;
    esac
}

# Change SSH Port
change_ssh_port() {
    clear
    echo -e "${BLUE}=== Change SSH Port ===${NC}"
    read -p "Enter new SSH port: " ssh_port
    sed -i "s/^Port .*/Port $ssh_port/" /etc/ssh/sshd_config
    systemctl restart ssh
    echo -e "${GREEN}SSH port updated to $ssh_port${NC}"
}

# Change SSH Banner
change_banner() {
    clear
    echo -e "${BLUE}=== Change SSH Banner ===${NC}"
    echo -e "Current banner:"
    cat /etc/issue.net
    echo -e "\nEnter new banner text (Ctrl+D when done):"
    cat > /etc/issue.net
    systemctl restart ssh
    echo -e "${GREEN}Banner updated${NC}"
}

# Main Menu
while true; do
    clear
    echo -e "${BLUE}=== SSH & WebSocket Manager ===${NC}"
    echo -e "1) Create SSH User"
    echo -e "2) Delete SSH User"
    echo -e "3) Extend User Expiry"
    echo -e "4) View SSH Users"
    echo -e "5) Monitor SSH Users"
    echo -e "6) WebSocket Settings"
    echo -e "7) Change SSH Port"
    echo -e "8) Change SSH Banner"
    echo -e "0) Back to Main Menu"
    
    read -p "Select option: " option
    case $option in
        1) create_ssh_user ;;
        2) delete_ssh_user ;;
        3) extend_user ;;
        4) view_users ;;
        5) monitor_users ;;
        6) websocket_settings ;;
        7) change_ssh_port ;;
        8) change_banner ;;
        0) break ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -p "Press enter to continue..."
done 