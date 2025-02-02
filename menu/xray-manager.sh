#!/bin/bash
# XRAY Manager Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Generate random string
generate_string() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
}

# Add VMESS User
add_vmess_user() {
    clear
    echo -e "${BLUE}=== Add VMESS User ===${NC}"
    read -p "Username: " user
    read -p "Duration (days): " duration
    
    uuid=$(cat /proc/sys/kernel/random/uuid)
    exp_date=$(date -d "+${duration} days" +"%Y-%m-%d")
    
    # Add to XRAY config
    jq --arg user "$user" --arg uuid "$uuid" '.inbounds[0].settings.clients += [{"id": $uuid, "email": $user, "alterId": 0}]' /usr/local/etc/xray/config.json > /tmp/tmp.json
    mv /tmp/tmp.json /usr/local/etc/xray/config.json
    
    # Save user info
    echo "vmess $user $uuid $exp_date" >> /root/xray_users.txt
    
    # Create user config
    domain=$(curl -s ifconfig.me)
    
    # WS Config
    cat > /home/$user/vmess-ws.json <<EOF
{
  "v": "2",
  "ps": "${user}-ws",
  "add": "${domain}",
  "port": "8443",
  "id": "${uuid}",
  "aid": "0",
  "net": "ws",
  "path": "/vmess",
  "type": "none",
  "host": "",
  "tls": "tls"
}
EOF

    # gRPC Config
    cat > /home/$user/vmess-grpc.json <<EOF
{
  "v": "2",
  "ps": "${user}-grpc",
  "add": "${domain}",
  "port": "2053",
  "id": "${uuid}",
  "aid": "0",
  "net": "grpc",
  "path": "vmess-grpc",
  "type": "none",
  "host": "",
  "tls": "tls"
}
EOF

    systemctl restart xray
    
    echo -e "${GREEN}VMESS User Added Successfully${NC}"
    echo -e "Username: $user"
    echo -e "UUID: $uuid"
    echo -e "Expires: $exp_date"
    echo -e "Config files saved in: /home/$user/"
}

# Add VLESS User
add_vless_user() {
    clear
    echo -e "${BLUE}=== Add VLESS User ===${NC}"
    read -p "Username: " user
    read -p "Duration (days): " duration
    
    uuid=$(cat /proc/sys/kernel/random/uuid)
    exp_date=$(date -d "+${duration} days" +"%Y-%m-%d")
    
    # Add to XRAY config
    jq --arg user "$user" --arg uuid "$uuid" '.inbounds[2].settings.clients += [{"id": $uuid, "email": $user, "flow": "xtls-rprx-direct"}]' /usr/local/etc/xray/config.json > /tmp/tmp.json
    mv /tmp/tmp.json /usr/local/etc/xray/config.json
    
    # Save user info
    echo "vless $user $uuid $exp_date" >> /root/xray_users.txt
    
    domain=$(curl -s ifconfig.me)
    
    # Create user config
    mkdir -p /home/$user
    cat > /home/$user/vless-config.txt <<EOF
VLESS Configuration:
===================
Remarks: ${user}
Domain: ${domain}
Port: 8880
UUID: ${uuid}
Network: ws
Path: /vless
TLS: false

VLESS XTLS:
Port: 2083
Flow: xtls-rprx-direct
Security: xtls

VLESS gRPC:
Port: 2083
ServiceName: vless-grpc
Security: tls
EOF

    systemctl restart xray
    
    echo -e "${GREEN}VLESS User Added Successfully${NC}"
    echo -e "Username: $user"
    echo -e "UUID: $uuid"
    echo -e "Expires: $exp_date"
    echo -e "Config saved in: /home/$user/vless-config.txt"
}

# Add TROJAN User
add_trojan_user() {
    clear
    echo -e "${BLUE}=== Add TROJAN User ===${NC}"
    read -p "Username: " user
    read -p "Duration (days): " duration
    
    password=$(generate_string 16)
    exp_date=$(date -d "+${duration} days" +"%Y-%m-%d")
    
    # Add to XRAY config
    jq --arg user "$user" --arg pass "$password" '.inbounds[4].settings.clients += [{"password": $pass, "email": $user}]' /usr/local/etc/xray/config.json > /tmp/tmp.json
    mv /tmp/tmp.json /usr/local/etc/xray/config.json
    
    # Save user info
    echo "trojan $user $password $exp_date" >> /root/xray_users.txt
    
    domain=$(curl -s ifconfig.me)
    
    # Create user config
    mkdir -p /home/$user
    cat > /home/$user/trojan-config.txt <<EOF
TROJAN Configuration:
====================
Remarks: ${user}
Domain: ${domain}
Port: 2087
Password: ${password}
Network: ws
Path: /trojan
Security: tls

TROJAN gRPC:
Port: 2096
ServiceName: trojan-grpc
Security: tls
EOF

    systemctl restart xray
    
    echo -e "${GREEN}TROJAN User Added Successfully${NC}"
    echo -e "Username: $user"
    echo -e "Password: $password"
    echo -e "Expires: $exp_date"
    echo -e "Config saved in: /home/$user/trojan-config.txt"
}

# Delete User
delete_user() {
    clear
    echo -e "${BLUE}=== Delete XRAY User ===${NC}"
    echo -e "Current users:"
    cat /root/xray_users.txt
    
    read -p "Enter username to delete: " user
    
    # Remove from config file based on email field
    jq --arg user "$user" 'walk(if type == "object" and .clients then .clients |= map(select(.email != $user)) else . end)' /usr/local/etc/xray/config.json > /tmp/tmp.json
    mv /tmp/tmp.json /usr/local/etc/xray/config.json
    
    # Remove from user database
    sed -i "/\s${user}\s/d" /root/xray_users.txt
    
    # Remove user directory
    rm -rf /home/$user
    
    systemctl restart xray
    echo -e "${GREEN}User $user deleted successfully${NC}"
}

# View Users
view_users() {
    clear
    echo -e "${BLUE}=== XRAY Users List ===${NC}"
    echo -e "Type\tUsername\tUUID/Password\tExpiry"
    echo -e "====\t========\t=============\t======"
    
    while IFS=' ' read -r type user uuid exp; do
        if [ ! -z "$type" ]; then
            today=$(date +%s)
            expiry=$(date -d "$exp" +%s)
            
            if [ $expiry -gt $today ]; then
                status="${GREEN}Active${NC}"
            else
                status="${RED}Expired${NC}"
            fi
            
            echo -e "$type\t$user\t${uuid:0:16}...\t$exp ($status)"
        fi
    done < /root/xray_users.txt
}

# Show Config
show_config() {
    clear
    echo -e "${BLUE}=== XRAY Configuration ===${NC}"
    echo -e "1) Show VMESS Config"
    echo -e "2) Show VLESS Config"
    echo -e "3) Show TROJAN Config"
    echo -e "4) Show Full Config"
    echo -e "0) Back"
    
    read -p "Select option: " config_choice
    case $config_choice in
        1) cat /usr/local/etc/xray/config.json | jq '.inbounds[] | select(.protocol == "vmess")' ;;
        2) cat /usr/local/etc/xray/config.json | jq '.inbounds[] | select(.protocol == "vless")' ;;
        3) cat /usr/local/etc/xray/config.json | jq '.inbounds[] | select(.protocol == "trojan")' ;;
        4) cat /usr/local/etc/xray/config.json | jq ;;
        0) return ;;
    esac
}

# Change Port
change_port() {
    clear
    echo -e "${BLUE}=== Change XRAY Ports ===${NC}"
    echo -e "1) Change VMESS WS Port (current: 8443)"
    echo -e "2) Change VMESS gRPC Port (current: 2053)"
    echo -e "3) Change VLESS Port (current: 8880)"
    echo -e "4) Change VLESS gRPC Port (current: 2083)"
    echo -e "5) Change TROJAN WS Port (current: 2087)"
    echo -e "6) Change TROJAN gRPC Port (current: 2096)"
    echo -e "0) Back"
    
    read -p "Select option: " port_choice
    case $port_choice in
        [1-6])
            read -p "Enter new port: " new_port
            local index=$((port_choice - 1))
            jq --arg port "$new_port" ".inbounds[$index].port = \$port" /usr/local/etc/xray/config.json > /tmp/tmp.json
            mv /tmp/tmp.json /usr/local/etc/xray/config.json
            systemctl restart xray
            echo -e "${GREEN}Port updated successfully${NC}"
            ;;
        0) return ;;
    esac
}

# Main Menu
while true; do
    clear
    echo -e "${BLUE}=== XRAY Manager ===${NC}"
    echo -e "1) Add VMESS User"
    echo -e "2) Add VLESS User"
    echo -e "3) Add TROJAN User"
    echo -e "4) Delete User"
    echo -e "5) View Users"
    echo -e "6) Show Config"
    echo -e "7) Change Port"
    echo -e "8) Renew Certificate"
    echo -e "0) Back to Main Menu"
    
    read -p "Select option: " option
    case $option in
        1) add_vmess_user ;;
        2) add_vless_user ;;
        3) add_trojan_user ;;
        4) delete_user ;;
        5) view_users ;;
        6) show_config ;;
        7) change_port ;;
        8) certbot renew ;;
        0) break ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -p "Press enter to continue..."
done 