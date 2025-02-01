#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Paths
XRAY_DB="/etc/xray/config.json"
XRAY_CERT="/etc/xray/xray.crt"
XRAY_KEY="/etc/xray/xray.key"

# Print functions
print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to return to menu
return_to_menu() {
    echo -e ""
    read -n 1 -s -r -p "Press any key to return to menu"
    clear
    exec menu-xray
}

# Install XRAY
install_xray() {
    print_info "Installing XRAY..."
    
    # Install dependencies
    apt-get update
    apt-get install -y curl socat jq

    # Download and install Xray
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
    
    # Create config directory if it doesn't exist
    mkdir -p /etc/xray
    
    # Generate default config if it doesn't exist
    if [ ! -f "$XRAY_DB" ]; then
        cat > "$XRAY_DB" << 'EOF'
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/etc/xray/xray.crt",
              "keyFile": "/etc/xray/xray.key"
            }
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF
    fi
    
    # Generate self-signed certificate if it doesn't exist
    if [ ! -f "$XRAY_CERT" ] || [ ! -f "$XRAY_KEY" ]; then
        print_info "Generating self-signed certificate..."
        openssl req -x509 -newkey rsa:4096 -keyout "$XRAY_KEY" -out "$XRAY_CERT" -days 365 -nodes -subj "/CN=localhost"
    fi
    
    # Start XRAY service
    systemctl enable xray
    systemctl restart xray
    
    if systemctl is-active --quiet xray; then
        print_success "XRAY installed and configured successfully"
    else
        print_error "Failed to start XRAY service"
        return 1
    fi
}

# Protocol-specific menus
vless_menu() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}              ${CYAN}VLESS MANAGER${NC}                       ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " ${GREEN}1)${NC} Create VLESS Account"
    echo -e " ${GREEN}2)${NC} Delete VLESS Account"
    echo -e " ${GREEN}3)${NC} List VLESS Users"
    echo -e " ${RED}0)${NC} Back to XRAY Menu"
    echo -e ""
    echo -ne "Select an option [0-3]: "
    read opt
    
    case $opt in
        1) create_account "vless" ;;
        2) delete_account "vless" ;;
        3) list_members "vless" ;;
        0) exec menu-xray ;;
        *) vless_menu ;;
    esac
}

vmess_menu() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}              ${CYAN}VMESS MANAGER${NC}                       ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " ${GREEN}1)${NC} Create VMESS Account"
    echo -e " ${GREEN}2)${NC} Delete VMESS Account"
    echo -e " ${GREEN}3)${NC} List VMESS Users"
    echo -e " ${RED}0)${NC} Back to XRAY Menu"
    echo -e ""
    echo -ne "Select an option [0-3]: "
    read opt
    
    case $opt in
        1) create_account "vmess" ;;
        2) delete_account "vmess" ;;
        3) list_members "vmess" ;;
        0) exec menu-xray ;;
        *) vmess_menu ;;
    esac
}

trojan_menu() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}             ${CYAN}TROJAN MANAGER${NC}                       ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " ${GREEN}1)${NC} Create Trojan Account"
    echo -e " ${GREEN}2)${NC} Delete Trojan Account"
    echo -e " ${GREEN}3)${NC} List Trojan Users"
    echo -e " ${RED}0)${NC} Back to XRAY Menu"
    echo -e ""
    echo -ne "Select an option [0-3]: "
    read opt
    
    case $opt in
        1) create_account "trojan" ;;
        2) delete_account "trojan" ;;
        3) list_members "trojan" ;;
        0) exec menu-xray ;;
        *) trojan_menu ;;
    esac
}

# Create account for specific protocol
create_account() {
    local proto=$1
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}            ${CYAN}CREATE ${proto^^} ACCOUNT${NC}                  ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    read -p "Username : " username
    read -p "Duration (days) : " duration
    
    # Generate UUID/Password
    local id
    if [ "$proto" = "trojan" ]; then
        id=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16)
    else
        id=$(xray uuid)
    fi
    
    # Add client to config based on protocol
    local tmp=$(mktemp)
    case $proto in
        "vless")
            jq --arg id "$id" --arg email "$username" \
                '.inbounds[] | select(.protocol == "vless") | .settings.clients += [{"id": $id, "email": $email}]' \
                "$XRAY_DB" > "$tmp"
            ;;
        "vmess")
            jq --arg id "$id" --arg email "$username" \
                '.inbounds[] | select(.protocol == "vmess") | .settings.clients += [{"id": $id, "email": $email, "alterId": 0}]' \
                "$XRAY_DB" > "$tmp"
            ;;
        "trojan")
            jq --arg id "$id" --arg email "$username" \
                '.inbounds[] | select(.protocol == "trojan") | .settings.clients += [{"password": $id, "email": $email}]' \
                "$XRAY_DB" > "$tmp"
            ;;
    esac
    mv "$tmp" "$XRAY_DB"
    
    # Restart service
    systemctl restart xray
    
    print_success "Account created successfully"
    echo -e "Username : $username"
    echo -e "ID/Pass  : $id"
    echo -e "Protocol : ${proto^^}"
    echo -e "Duration : $duration Days"
    echo -e "Expires  : $(date -d "+$duration days" +"%Y-%m-%d")"
}

# List XRAY users
list_members() {
    local proto=$1
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}               ${CYAN}XRAY MEMBER LIST${NC}                   ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    echo -e "USERNAME          ID/Pass"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    jq -r ".inbounds[] | select(.protocol == \"$proto\") | .settings.clients[] | \"\(.email) \(.id)\"" "$XRAY_DB" | \
    while read -r email id; do
        printf "%-15s %s\n" "$email" "$id"
    done
}

# Delete XRAY account
delete_account() {
    local proto=$1
    read -p "Username to delete: " username
    
    tmp=$(mktemp)
    jq --arg user "$username" ".inbounds[] | select(.protocol == \"$proto\") | .settings.clients = [.inbounds[].settings.clients[] | select(.email != $user)]" "$XRAY_DB" > "$tmp"
    mv "$tmp" "$XRAY_DB"
    
    systemctl restart xray
    print_success "Account $username deleted"
}

# Main script
case "$1" in
    "install")
        install_xray
        return_to_menu
        ;;
    "vless-menu")
        vless_menu
        ;;
    "vmess-menu")
        vmess_menu
        ;;
    "trojan-menu")
        trojan_menu
        ;;
    "list-all")
        list_all_members
        return_to_menu
        ;;
    "status")
        check_status
        return_to_menu
        ;;
    "update-cert")
        update_certificate
        return_to_menu
        ;;
    *)
        print_error "Usage: $0 {install|vless-menu|vmess-menu|trojan-menu|list-all|status|update-cert}"
        exit 1
        ;;
esac 