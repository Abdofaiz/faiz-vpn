#!/bin/bash
# SlowDNS Manager Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create SlowDNS User
create_user() {
    clear
    echo -e "${BLUE}=== Create SlowDNS User ===${NC}"
    read -p "Username: " user
    read -p "Password: " pass
    read -p "Duration (days): " duration
    
    # Calculate expiry
    exp_date=$(date -d "+${duration} days" +"%Y-%m-%d")
    
    # Create system user
    useradd -e "$exp_date" -s /bin/false "$user"
    echo "$user:$pass" | chpasswd
    
    # Save user info
    echo "$user $pass $exp_date" >> /root/slowdns_users.txt
    
    # Get server info
    SERVER_IP=$(curl -s ifconfig.me)
    NS_DOMAIN=$(cat /etc/resolv.conf | grep nameserver | head -n1 | awk '{print $2}')
    SERVER_PUB=$(cat /root/server.pub)
    
    # Generate client config
    mkdir -p /home/$user/slowdns
    cat > /home/$user/slowdns/config.txt <<EOF
SlowDNS Configuration:
=====================
Server IP: $SERVER_IP
NS Domain: $NS_DOMAIN
Public Key: $SERVER_PUB
Username: $user
Password: $pass
Expires: $exp_date

Client Setup Instructions:
1. Install SlowDNS client
2. Save the public key as 'client.pub'
3. Run client with:
   ./slowdns client -udpport=5300 -dnsip=$NS_DOMAIN -pubkey=client.pub -server=$SERVER_IP

For Android:
1. Install SlowDNS app
2. Server: $SERVER_IP
3. Public Key: $SERVER_PUB
4. DNS Server: $NS_DOMAIN
5. Username: $user
6. Password: $pass
EOF
    
    echo -e "${GREEN}User created successfully!${NC}"
    echo -e "Username: $user"
    echo -e "Password: $pass"
    echo -e "Expires: $exp_date"
    echo -e "Config saved in: /home/$user/slowdns/config.txt"
}

# Delete SlowDNS User
delete_user() {
    clear
    echo -e "${BLUE}=== Delete SlowDNS User ===${NC}"
    read -p "Username to delete: " user
    
    if id "$user" &>/dev/null; then
        userdel -r "$user"
        sed -i "/^$user /d" /root/slowdns_users.txt
        echo -e "${GREEN}User $user deleted successfully${NC}"
    else
        echo -e "${RED}User $user not found${NC}"
    fi
}

# Extend User
extend_user() {
    clear
    echo -e "${BLUE}=== Extend SlowDNS User ===${NC}"
    read -p "Username: " user
    read -p "Add days: " add_days
    
    if id "$user" &>/dev/null; then
        # Get current expiry
        curr_exp=$(chage -l $user | grep "Account expires" | cut -d: -f2)
        # Calculate new expiry
        new_exp=$(date -d "$curr_exp +$add_days days" +"%Y-%m-%d")
        chage -E "$new_exp" "$user"
        # Update database
        sed -i "s/^$user .* /&$new_exp/" /root/slowdns_users.txt
        echo -e "${GREEN}Expiry date extended to $new_exp${NC}"
    else
        echo -e "${RED}User $user not found${NC}"
    fi
}

# View Users
view_users() {
    clear
    echo -e "${BLUE}=== SlowDNS Users List ===${NC}"
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
    done < /root/slowdns_users.txt
}

# Monitor Users
monitor_users() {
    clear
    echo -e "${BLUE}=== Active SlowDNS Connections ===${NC}"
    echo -e "Username\tIP Address\tConnected Since"
    echo -e "========\t==========\t==============="
    
    # Get active connections
    netstat -anp | grep "slowdns" | grep "ESTABLISHED" | while read line; do
        pid=$(echo $line | awk '{print $7}' | cut -d'/' -f1)
        if [ ! -z "$pid" ]; then
            user=$(ps -p $pid -o user= | tr -d ' ')
            ip=$(echo $line | awk '{print $5}')
            since=$(ps -o etime= -p $pid)
            echo -e "$user\t$ip\t$since"
        fi
    done
}

# Server Settings
server_settings() {
    clear
    echo -e "${BLUE}=== SlowDNS Server Settings ===${NC}"
    echo -e "1) Change DNS Port"
    echo -e "2) Change UDP Port"
    echo -e "3) Regenerate Keys"
    echo -e "4) Show Server Status"
    echo -e "0) Back"
    
    read -p "Select option: " settings_choice
    case $settings_choice in
        1)
            read -p "Enter new DNS port: " dns_port
            sed -i "s/-dnsport=[0-9]*/-dnsport=$dns_port/" /etc/systemd/system/slowdns-server.service
            systemctl daemon-reload
            systemctl restart slowdns-server
            echo -e "${GREEN}DNS port updated to $dns_port${NC}"
            ;;
        2)
            read -p "Enter new UDP port: " udp_port
            sed -i "s/-udpport=[0-9]*/-udpport=$udp_port/" /etc/systemd/system/slowdns-server.service
            systemctl daemon-reload
            systemctl restart slowdns-server
            echo -e "${GREEN}UDP port updated to $udp_port${NC}"
            ;;
        3)
            cd /usr/local/slowdns/slowdns
            ./slowdns keygen
            mv server.key /root/server.key
            mv server.pub /root/server.pub
            systemctl restart slowdns-server
            echo -e "${GREEN}Keys regenerated successfully${NC}"
            ;;
        4)
            systemctl status slowdns-server
            ;;
        0) return ;;
    esac
}

# Main Menu
while true; do
    clear
    echo -e "${BLUE}=== SlowDNS Manager ===${NC}"
    echo -e "1) Create User"
    echo -e "2) Delete User"
    echo -e "3) Extend User"
    echo -e "4) View Users"
    echo -e "5) Monitor Users"
    echo -e "6) Server Settings"
    echo -e "7) Show Server Status"
    echo -e "0) Back to Main Menu"
    
    read -p "Select option: " option
    case $option in
        1) create_user ;;
        2) delete_user ;;
        3) extend_user ;;
        4) view_users ;;
        5) monitor_users ;;
        6) server_settings ;;
        7) systemctl status slowdns-server ;;
        0) break ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -p "Press enter to continue..."
done 