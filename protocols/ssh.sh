#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Paths
SSH_DB="/etc/ssh/.ssh.db"
CONFIG_DIR="/etc/vpn"

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

# User Management Functions
create_account() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}            ${CYAN}CREATE SSH ACCOUNT${NC}                    ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    read -p "Username : " username
    read -p "Password : " password
    read -p "Duration (days) : " duration
    
    # Check if username exists
    if grep -q "^### $username" "$SSH_DB"; then
        print_error "Username already exists"
        return 1
    fi
    
    # Create account
    useradd -e $(date -d "+$duration days" +"%Y-%m-%d") -s /bin/false -M $username
    echo -e "$password\n$password" | passwd $username &> /dev/null
    
    # Save to database
    echo "### $username $password $(date +%s) $duration" >> "$SSH_DB"
    
    print_success "Account created successfully"
    echo -e "Username : $username"
    echo -e "Password : $password"
    echo -e "Duration : $duration Days"
    echo -e "Expires  : $(date -d "+$duration days" +"%Y-%m-%d")"
}

trial_account() {
    username="trial$(date +%s)"
    password="trial$(date +%d%m)"
    duration=1
    
    useradd -e $(date -d "+$duration days" +"%Y-%m-%d") -s /bin/false -M $username
    echo -e "$password\n$password" | passwd $username &> /dev/null
    echo "### $username $password $(date +%s) $duration" >> "$SSH_DB"
    
    print_success "Trial account created"
    echo -e "Username : $username"
    echo -e "Password : $password"
    echo -e "Duration : $duration Day"
}

delete_account() {
    read -p "Username to delete: " username
    if grep -q "^### $username" "$SSH_DB"; then
        userdel -f $username
        sed -i "/^### $username/d" "$SSH_DB"
        print_success "Account $username deleted"
    else
        print_error "Username not found"
    fi
}

list_members() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}               ${CYAN}SSH MEMBER LIST${NC}                    ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    echo -e "USERNAME          EXPIRY DATE"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    while IFS= read -r line; do
        if [[ $line =~ ^###\ ([^\ ]+) ]]; then
            username="${BASH_REMATCH[1]}"
            expiry=$(chage -l "$username" | grep "Account expires" | cut -d: -f2)
            printf "%-15s %s\n" "$username" "$expiry"
        fi
    done < "$SSH_DB"
}

check_login() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}             ${CYAN}SSH LOGIN MONITOR${NC}                    ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    data=($(ps aux | grep -i sshd | grep -i priv | awk '{print $2}'))
    echo -e "ID  USERNAME       IP ADDRESS"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    for pid in "${data[@]}"; do
        if [ "$(cat /proc/$pid/comm 2>/dev/null)" = "sshd" ]; then
            user=$(cat /proc/$pid/environ | tr '\0' '\n' | grep '^USER=' | cut -d= -f2)
            ip=$(netstat -np 2>/dev/null | grep $pid | awk '{print $5}' | cut -d: -f1)
            if [ ! -z "$user" ] && [ ! -z "$ip" ]; then
                printf "%-3s %-13s %s\n" "$pid" "$user" "$ip"
            fi
        fi
    done
}

# Install and configure OpenSSH
install_ssh() {
    print_info "Installing OpenSSH..."
    
    # Backup existing config if it exists
    if [ -f "/etc/ssh/sshd_config" ]; then
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        print_info "Existing SSH config backed up"
    fi
    
    # Install OpenSSH if not installed
    if ! dpkg -l | grep -q openssh-server; then
        apt-get update
        apt-get install -y openssh-server || {
            print_error "Failed to install OpenSSH"
            return 1
        }
    fi
    
    # Configure SSH
    cat > /etc/ssh/sshd_config << 'EOF'
Port 443
Port 80
AddressFamily inet
ListenAddress 0.0.0.0
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
PermitRootLogin yes
MaxSessions 1024
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
ClientAliveInterval 240
ClientAliveCountMax 2
UseDNS no
EOF
    
    # Test config
    sshd -t || {
        print_error "SSH config test failed"
        if [ -f "/etc/ssh/sshd_config.bak" ]; then
            mv /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
            print_info "Restored backup config"
        fi
        return 1
    }
    
    # Restart SSH service
    systemctl restart ssh || {
        print_error "Failed to restart SSH service"
        return 1
    }
    
    # Verify service is running
    if systemctl is-active --quiet ssh; then
        print_success "OpenSSH installed and configured for ports 443 and 80"
    else
        print_error "SSH service failed to start"
        return 1
    fi
}

# Check SSH status
check_ssh() {
    print_info "Checking SSH service status..."
    
    # Check if service is running
    if systemctl is-active --quiet ssh; then
        print_success "SSH service is running"
        
        # Check listening ports
        if netstat -tuln | grep -q ':443 '; then
            print_success "Port 443 is active"
        else
            print_error "Port 443 is not listening"
        fi
        
        if netstat -tuln | grep -q ':80 '; then
            print_success "Port 80 is active"
        else
            print_error "Port 80 is not listening"
        fi
    else
        print_error "SSH service is not running"
        return 1
    fi
}

renew_account() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}            ${CYAN}RENEW SSH ACCOUNT${NC}                    ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    read -p "Username to renew: " username
    read -p "Add days: " duration
    
    if grep -q "^### $username" "$SSH_DB"; then
        # Update expiry
        chage -E $(date -d "+$duration days" +"%Y-%m-%d") $username
        print_success "Account renewed successfully"
        echo -e "New expiry: $(date -d "+$duration days" +"%Y-%m-%d")"
    else
        print_error "Username not found"
    fi
}

delete_expired() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}           ${CYAN}DELETE EXPIRED USERS${NC}                  ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    count=0
    while IFS= read -r line; do
        if [[ $line =~ ^###\ ([^\ ]+) ]]; then
            username="${BASH_REMATCH[1]}"
            exp=$(chage -l "$username" | grep "Account expires" | cut -d: -f2)
            exp_date=$(date -d "$exp" +%s)
            today=$(date +%s)
            if [ $today -gt $exp_date ]; then
                userdel -f "$username"
                sed -i "/^### $username/d" "$SSH_DB"
                ((count++))
            fi
        fi
    done < "$SSH_DB"
    
    print_success "Deleted $count expired users"
}

setup_autokill() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}            ${CYAN}AUTOKILL SSH SETUP${NC}                   ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    read -p "Max Multi Login (1-10): " max
    if [[ $max =~ ^[1-9]|10$ ]]; then
        echo "$max" > /etc/ssh/max_login
        print_success "Autokill set to $max multi login"
    else
        print_error "Invalid input. Please enter a number between 1-10"
    fi
}

check_multi() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}           ${CYAN}MULTI LOGIN CHECKER${NC}                   ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    if [ -f "/etc/ssh/max_login" ]; then
        max_login=$(cat /etc/ssh/max_login)
    else
        max_login=2
    fi
    
    echo -e "USERNAME       LOGIN COUNT"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    while IFS= read -r line; do
        if [[ $line =~ ^###\ ([^\ ]+) ]]; then
            username="${BASH_REMATCH[1]}"
            count=$(ps -u "$username" | grep -v "ps" | wc -l)
            if [ $count -gt $max_login ]; then
                printf "%-13s %d (KILLED)\n" "$username" "$count"
                pkill -u "$username"
            else
                printf "%-13s %d\n" "$username" "$count"
            fi
        fi
    done < "$SSH_DB"
}

# Function to return to menu
return_to_menu() {
    echo -e ""
    read -n 1 -s -r -p "Press any key to return to menu"
    clear
    exec menu-ssh
}

# Main script
case "$1" in
    "create")
        create_account
        return_to_menu
        ;;
    "trial")
        trial_account
        return_to_menu
        ;;
    "renew")
        renew_account
        return_to_menu
        ;;
    "delete")
        delete_account
        return_to_menu
        ;;
    "list")
        list_members
        return_to_menu
        ;;
    "check")
        check_login
        return_to_menu
        ;;
    "expired")
        delete_expired
        return_to_menu
        ;;
    "autokill")
        setup_autokill
        return_to_menu
        ;;
    "multi")
        check_multi
        return_to_menu
        ;;
    "install")
        install_ssh
        return_to_menu
        ;;
    "restart")
        systemctl restart ssh && print_success "SSH service restarted" || print_error "Failed to restart SSH"
        return_to_menu
        ;;
    *)
        print_error "Usage: $0 {create|trial|renew|delete|list|check|expired|autokill|multi|install|restart}"
        exit 1
        ;;
esac 