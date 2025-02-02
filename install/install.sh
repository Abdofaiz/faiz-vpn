#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
NC='\033[0m'

# Paths
SCRIPT_DIR="/usr/local/vpn-script"
INSTALL_DIR="$SCRIPT_DIR/install"

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}            ${CYAN}VPN SCRIPT INSTALLER${NC}                  ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Source installation modules
source $INSTALL_DIR/core/packages.sh
source $INSTALL_DIR/core/domain.sh
source $INSTALL_DIR/core/services.sh

# Install core packages
echo -e "${CYAN}Installing core packages...${NC}"
install_packages

# Setup domain and SSL
echo -e "${CYAN}Setting up domain and SSL...${NC}"
setup_domain

# Install protocols
echo -e "${CYAN}Installing protocols...${NC}"
source $INSTALL_DIR/protocols/ssh.sh
source $INSTALL_DIR/protocols/vmess.sh
source $INSTALL_DIR/protocols/vless.sh
source $INSTALL_DIR/protocols/trojan.sh

# Setup services
echo -e "${CYAN}Setting up services...${NC}"
setup_services

echo -e "${GREEN}Installation completed!${NC}"
echo -e "Your server now supports:"
echo -e "1. SSH/OpenVPN"
echo -e "   - Direct SSH"
echo -e "   - WebSocket TLS/Non-TLS"
echo -e "   - SSL/TLS"
echo -e ""
echo -e "2. XRAY"
echo -e "   - VMESS WS TLS/Non-TLS"
echo -e "   - VLESS WS TLS/Non-TLS"
echo -e "   - VLESS XTLS"
echo -e "   - TROJAN WS/TCP" 