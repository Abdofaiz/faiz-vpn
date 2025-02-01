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

# Create XRAY account
create_account() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}            ${CYAN}CREATE XRAY ACCOUNT${NC}                   ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    read -p "Username : " username
    read -p "Duration (days) : " duration
    
    # Generate UUID
    uuid=$(xray uuid)
    
    # Add client to config
    tmp=$(mktemp)
    jq --arg uuid "$uuid" '.inbounds[0].settings.clients += [{"id": $uuid, "email": "'"$username"'"}]' "$XRAY_DB" > "$tmp"
    mv "$tmp" "$XRAY_DB"
    
    # Restart service
    systemctl restart xray
    
    print_success "Account created successfully"
    echo -e "Username : $username"
    echo -e "UUID     : $uuid"
    echo -e "Duration : $duration Days"
    echo -e "Expires  : $(date -d "+$duration days" +"%Y-%m-%d")"
}

# List XRAY users
list_members() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}               ${CYAN}XRAY MEMBER LIST${NC}                   ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    echo -e "USERNAME          UUID"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    jq -r '.inbounds[0].settings.clients[] | "\(.email) \(.id)"' "$XRAY_DB" | \
    while read -r email uuid; do
        printf "%-15s %s\n" "$email" "$uuid"
    done
}

# Delete XRAY account
delete_account() {
    read -p "Username to delete: " username
    
    tmp=$(mktemp)
    jq --arg user "$username" '.inbounds[0].settings.clients = [.inbounds[0].settings.clients[] | select(.email != $user)]' "$XRAY_DB" > "$tmp"
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
    "create")
        create_account
        return_to_menu
        ;;
    "list")
        list_members
        return_to_menu
        ;;
    "delete")
        delete_account
        return_to_menu
        ;;
    *)
        print_error "Usage: $0 {install|create|list|delete}"
        exit 1
        ;;
esac 