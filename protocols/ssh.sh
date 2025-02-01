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

# Main script
case "$1" in
    "install")
        install_ssh
        ;;
    "check")
        check_ssh
        ;;
    "restart")
        systemctl restart ssh && print_success "SSH service restarted" || print_error "Failed to restart SSH"
        ;;
    *)
        print_error "Usage: $0 {install|check|restart}"
        exit 1
        ;;
esac

exit 0 