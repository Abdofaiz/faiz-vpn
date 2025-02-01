#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

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
    exec menu-settings
}

# Change port settings
change_port() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}             ${CYAN}PORT SETTINGS${NC}                       ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    echo -e "1) Change SSH Port"
    echo -e "2) Change XRAY Ports"
    echo -e "0) Back"
    echo -e ""
    read -p "Select an option: " opt
    
    case $opt in
        1) change_ssh_port ;;
        2) change_xray_ports ;;
        0) return_to_menu ;;
        *) change_port ;;
    esac
}

# Change domain
change_domain() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}             ${CYAN}DOMAIN SETTINGS${NC}                     ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    read -p "Enter new domain: " domain
    echo "$domain" > /etc/xray/domain
    
    # Update certificates
    ~/.acme.sh/acme.sh --issue -d "$domain" --standalone
    ~/.acme.sh/acme.sh --installcert -d "$domain" \
        --key-file /etc/xray/xray.key \
        --fullchain-file /etc/xray/xray.crt
    
    systemctl restart xray
    print_success "Domain updated to $domain"
}

# Change banner
change_banner() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}             ${CYAN}BANNER SETTINGS${NC}                     ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    echo -e "Enter new banner text (Ctrl+D when done):"
    cat > /etc/issue.net
    print_success "Banner updated"
}

# Restart services
restart_services() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}           ${CYAN}RESTARTING SERVICES${NC}                   ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    systemctl restart ssh
    systemctl restart xray
    systemctl restart nginx
    print_success "All services restarted"
}

# Check system status
check_status() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}             ${CYAN}SYSTEM STATUS${NC}                       ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    echo -e "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%"
    echo -e "Memory Usage: $(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}')"
    echo -e "Disk Usage: $(df -h / | awk 'NR==2{print $5}')"
    echo -e ""
    echo -e "Services Status:"
    echo -e "SSH: $(systemctl is-active ssh)"
    echo -e "XRAY: $(systemctl is-active xray)"
    echo -e "NGINX: $(systemctl is-active nginx)"
}

# Main script
case "$1" in
    "port")
        change_port
        return_to_menu
        ;;
    "domain")
        change_domain
        return_to_menu
        ;;
    "banner")
        change_banner
        return_to_menu
        ;;
    "restart")
        restart_services
        return_to_menu
        ;;
    "status")
        check_status
        return_to_menu
        ;;
    *)
        print_error "Usage: $0 {port|domain|banner|restart|status}"
        exit 1
        ;;
esac 