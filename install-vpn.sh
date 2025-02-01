#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root"
    exit 1
fi

# Create installation directory
mkdir -p /usr/local/vpn/
cd /usr/local/vpn/

# Download protocol scripts
download_scripts() {
    print_info "Downloading installation scripts..."
    
    # Define script URLs
    REPO_URL="raw.githubusercontent.com/yourusername/vpn-script/main"
    
    # Download individual protocol scripts
    wget -O ssh.sh "https://${REPO_URL}/protocols/ssh.sh"
    wget -O websocket.sh "https://${REPO_URL}/protocols/websocket.sh"
    wget -O xray.sh "https://${REPO_URL}/protocols/xray.sh"
    
    # Make scripts executable
    chmod +x *.sh
}

# Main installation
main_install() {
    print_info "Starting installation..."
    
    # Get server IP
    MYIP=$(wget -qO- ipv4.icanhazip.com)
    export MYIP
    
    # Download protocol scripts
    download_scripts
    
    # Execute protocol installations
    ./ssh.sh
    ./websocket.sh
    ./xray.sh
    
    print_success "Installation completed!"
    print_info "Server IP: $MYIP"
}

# Start installation
main_install 