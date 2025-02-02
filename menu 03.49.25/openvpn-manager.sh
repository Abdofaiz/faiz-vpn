#!/bin/bash
# OpenVPN Manager Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create OpenVPN User
create_user() {
    clear
    echo -e "${BLUE}=== Create OpenVPN User ===${NC}"
    read -p "Username: " user
    read -p "Password: " pass
    read -p "Duration (days): " duration
    
    # Calculate expiry
    exp_date=$(date -d "+${duration} days" +"%Y-%m-%d")
    
    # Add to auth file
    echo "$user" >> /etc/openvpn/server/auth.txt
    echo "$pass" >> /etc/openvpn/server/auth.txt
    
    # Save user info
    echo "$user $pass $exp_date" >> /root/openvpn_users.txt
    
    # Generate client configs
    mkdir -p /home/$user/openvpn
    
    # TCP Config
    cat > /home/$user/openvpn/tcp.ovpn <<EOF
client
dev tun
proto tcp
remote $(curl -s ifconfig.me) 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
key-direction 1
verb 3
auth-user-pass
<ca>
$(cat /etc/openvpn/server/ca.crt)
</ca>
<tls-auth>
$(cat /etc/openvpn/server/ta.key)
</tls-auth>
EOF

    # UDP Config
    cat > /home/$user/openvpn/udp.ovpn <<EOF
client
dev tun
proto udp
remote $(curl -s ifconfig.me) 2200
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
key-direction 1
verb 3
auth-user-pass
<ca>
$(cat /etc/openvpn/server/ca.crt)
</ca>
<tls-auth>
$(cat /etc/openvpn/server/ta.key)
</tls-auth>
EOF

    # SSL Config
    cat > /home/$user/openvpn/ssl.ovpn <<EOF
client
dev tun
proto tcp
remote $(curl -s ifconfig.me) 2086
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
key-direction 1
verb 3
auth-user-pass
http-proxy $(curl -s ifconfig.me) 8080
http-proxy-option CUSTOM-HEADER Host www.googleapis.com
<ca>
$(cat /etc/openvpn/server/ca.crt)
</ca>
<tls-auth>
$(cat /etc/openvpn/server/ta.key)
</tls-auth>
EOF

    # Create zip file
    cd /home/$user
    zip -r openvpn.zip openvpn/
    cd - > /dev/null
    
    echo -e "${GREEN}User created successfully!${NC}"
    echo -e "Username: $user"
    echo -e "Password: $pass"
    echo -e "Expires: $exp_date"
    echo -e "Config files saved in: /home/$user/openvpn.zip"
}

# Delete OpenVPN User
delete_user() {
    clear
    echo -e "${BLUE}=== Delete OpenVPN User ===${NC}"
    read -p "Username to delete: " user
    
    # Remove from auth file
    sed -i "/^$user$/d" /etc/openvpn/server/auth.txt
    # Remove next line (password)
    sed -i "1d" /etc/openvpn/server/auth.txt
    
    # Remove from database
    sed -i "/^$user /d" /root/openvpn_users.txt
    
    # Remove user files
    rm -rf /home/$user
    
    echo -e "${GREEN}User $user deleted successfully${NC}"
}

# Extend User
extend_user() {
    clear
    echo -e "${BLUE}=== Extend OpenVPN User ===${NC}"
    read -p "Username: " user
    read -p "Add days: " add_days
    
    # Check if user exists
    if grep -q "^$user " /root/openvpn_users.txt; then
        # Get current line
        curr_line=$(grep "^$user " /root/openvpn_users.txt)
        curr_exp=$(echo $curr_line | awk '{print $3}')
        
        # Calculate new expiry
        new_exp=$(date -d "$curr_exp +$add_days days" +"%Y-%m-%d")
        
        # Update database
        sed -i "s/$curr_exp/$new_exp/" /root/openvpn_users.txt
        
        echo -e "${GREEN}Expiry date extended to $new_exp${NC}"
    else
        echo -e "${RED}User $user not found${NC}"
    fi
}

# View Users
view_users() {
    clear
    echo -e "${BLUE}=== OpenVPN Users List ===${NC}"
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
    done < /root/openvpn_users.txt
}

# Monitor Users
monitor_users() {
    clear
    echo -e "${BLUE}=== Active OpenVPN Connections ===${NC}"
    echo -e "Username\tIP Address\tConnected Since"
    echo -e "========\t==========\t==============="
    
    # TCP Status
    echo -e "\n${YELLOW}TCP Connections:${NC}"
    cat /var/log/openvpn/openvpn-status.log 2>/dev/null | grep "CLIENT_LIST" | awk '{print $2"\t"$3"\t"$5" "$6" "$7" "$8}'
    
    # UDP Status
    echo -e "\n${YELLOW}UDP Connections:${NC}"
    cat /var/log/openvpn/openvpn-udp-status.log 2>/dev/null | grep "CLIENT_LIST" | awk '{print $2"\t"$3"\t"$5" "$6" "$7" "$8}'
}

# Change Port
change_port() {
    clear
    echo -e "${BLUE}=== Change OpenVPN Ports ===${NC}"
    echo -e "1) Change TCP Port (current: 1194)"
    echo -e "2) Change UDP Port (current: 2200)"
    echo -e "3) Change SSL Port (current: 2086)"
    echo -e "0) Back"
    
    read -p "Select option: " port_choice
    case $port_choice in
        1) 
            read -p "Enter new TCP port: " new_port
            sed -i "s/^port .*/port $new_port/" /etc/openvpn/server/server-tcp.conf
            systemctl restart openvpn-server@server-tcp
            ;;
        2)
            read -p "Enter new UDP port: " new_port
            sed -i "s/^port .*/port $new_port/" /etc/openvpn/server/server-udp.conf
            systemctl restart openvpn-server@server-udp
            ;;
        3)
            read -p "Enter new SSL port: " new_port
            sed -i "s/^port .*/port $new_port/" /etc/openvpn/server/server-ssl.conf
            systemctl restart openvpn-server@server-ssl
            ;;
        0) return ;;
    esac
    
    echo -e "${GREEN}Port updated successfully${NC}"
}

# Main Menu
while true; do
    clear
    echo -e "${BLUE}=== OpenVPN Manager ===${NC}"
    echo -e "1) Create User"
    echo -e "2) Delete User"
    echo -e "3) Extend User"
    echo -e "4) View Users"
    echo -e "5) Monitor Users"
    echo -e "6) Change Port"
    echo -e "7) Generate Config"
    echo -e "0) Back to Main Menu"
    
    read -p "Select option: " option
    case $option in
        1) create_user ;;
        2) delete_user ;;
        3) extend_user ;;
        4) view_users ;;
        5) monitor_users ;;
        6) change_port ;;
        7) create_user ;;
        0) break ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -p "Press enter to continue..."
done 