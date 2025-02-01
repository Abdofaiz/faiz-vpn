#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Paths
XRAY_CONFIG="/etc/xray/config.json"
XRAY_CERT="/etc/xray/xray.crt"
XRAY_KEY="/etc/xray/xray.key"
DOMAIN_FILE="/etc/xray/domain"

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
    apt-get install -y curl socat jq wget

    # Download and install Xray
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
    
    # Create config directory
    mkdir -p /etc/xray
    
    # Get domain
    read -p "Enter your domain: " domain
    echo "$domain" > "$DOMAIN_FILE"
    
    # Generate default config
    cat > "$XRAY_CONFIG" << EOF
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
              "certificateFile": "$XRAY_CERT",
              "keyFile": "$XRAY_KEY"
            }
          ]
        }
      }
    },
    {
      "port": 80,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmess"
        }
      }
    },
    {
      "port": 8443,
      "protocol": "trojan",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "$XRAY_CERT",
              "keyFile": "$XRAY_KEY"
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

    # Install SSL certificate
    print_info "Installing SSL certificate..."
    systemctl stop nginx
    curl https://get.acme.sh | sh
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    ~/.acme.sh/acme.sh --register-account -m admin@"$domain"
    ~/.acme.sh/acme.sh --issue -d "$domain" --standalone
    ~/.acme.sh/acme.sh --installcert -d "$domain" \
        --key-file "$XRAY_KEY" \
        --fullchain-file "$XRAY_CERT"
    
    # Start XRAY service
    systemctl enable xray
    systemctl restart xray
    
    if systemctl is-active --quiet xray; then
        print_success "XRAY installed and configured successfully"
        print_info "VLESS port: 443"
        print_info "VMESS port: 80"
        print_info "Trojan port: 8443"
    else
        print_error "Failed to start XRAY service"
        return 1
    fi
}

# Check XRAY status
check_status() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}             ${CYAN}XRAY STATUS CHECK${NC}                    ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    if systemctl is-active --quiet xray; then
        echo -e "XRAY Service: ${GREEN}Running${NC}"
        echo -e "Domain: $(cat $DOMAIN_FILE)"
        echo -e "VLESS Port: 443 (${GREEN}Active${NC})"
        echo -e "VMESS Port: 80 (${GREEN}Active${NC})"
        echo -e "Trojan Port: 8443 (${GREEN}Active${NC})"
    else
        echo -e "XRAY Service: ${RED}Not Running${NC}"
    fi
}

# Update SSL certificate
update_certificate() {
    domain=$(cat "$DOMAIN_FILE")
    print_info "Updating SSL certificate for $domain..."
    
    ~/.acme.sh/acme.sh --renew -d "$domain" --force
    ~/.acme.sh/acme.sh --installcert -d "$domain" \
        --key-file "$XRAY_KEY" \
        --fullchain-file "$XRAY_CERT"
    
    systemctl restart xray
    print_success "Certificate updated successfully"
}

# List all members
list_all_members() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}             ${CYAN}ALL XRAY MEMBERS${NC}                     ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    echo -e "PROTOCOL  USERNAME          ID/PASSWORD"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    for proto in vless vmess trojan; do
        jq -r ".inbounds[] | select(.protocol == \"$proto\") | .settings.clients[] | \"$proto \(.email) \(.id // .password)\"" "$XRAY_CONFIG" | \
        while read -r protocol email id; do
            printf "%-8s %-15s %s\n" "${protocol^^}" "$email" "$id"
        done
    done
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
                "$XRAY_CONFIG" > "$tmp"
            ;;
        "vmess")
            jq --arg id "$id" --arg email "$username" \
                '.inbounds[] | select(.protocol == "vmess") | .settings.clients += [{"id": $id, "email": $email, "alterId": 0}]' \
                "$XRAY_CONFIG" > "$tmp"
            ;;
        "trojan")
            jq --arg id "$id" --arg email "$username" \
                '.inbounds[] | select(.protocol == "trojan") | .settings.clients += [{"password": $id, "email": $email}]' \
                "$XRAY_CONFIG" > "$tmp"
            ;;
    esac
    mv "$tmp" "$XRAY_CONFIG"
    
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
    
    jq -r ".inbounds[] | select(.protocol == \"$proto\") | .settings.clients[] | \"\(.email) \(.id)\"" "$XRAY_CONFIG" | \
    while read -r email id; do
        printf "%-15s %s\n" "$email" "$id"
    done
}

# Delete XRAY account
delete_account() {
    local proto=$1
    read -p "Username to delete: " username
    
    tmp=$(mktemp)
    jq --arg user "$username" ".inbounds[] | select(.protocol == \"$proto\") | .settings.clients = [.inbounds[].settings.clients[] | select(.email != $user)]" "$XRAY_CONFIG" > "$tmp"
    mv "$tmp" "$XRAY_CONFIG"
    
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