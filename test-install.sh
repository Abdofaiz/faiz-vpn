#!/bin/bash
# Test Installation Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Testing installation...${NC}"

# Check required packages
echo -e "\n${YELLOW}Checking required packages:${NC}"
packages=("nginx" "xray" "python3" "stunnel4" "dropbear" "fail2ban")
for package in "${packages[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
        echo -e "$package: ${GREEN}Installed${NC}"
    else
        echo -e "$package: ${RED}Not installed${NC}"
        exit 1
    fi
done

# Check services
echo -e "\n${YELLOW}Checking services:${NC}"
services=("nginx" "xray" "stunnel4" "dropbear" "fail2ban")
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        echo -e "$service: ${GREEN}Running${NC}"
    else
        echo -e "$service: ${RED}Not running${NC}"
        exit 1
    fi
done

# Check configuration files
echo -e "\n${YELLOW}Checking config files:${NC}"
files=(
    "/usr/local/etc/xray/config.json"
    "/etc/nginx/conf.d/xray.conf"
    "/etc/stunnel/stunnel.conf"
    "/etc/default/dropbear"
)
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "$file: ${GREEN}Exists${NC}"
    else
        echo -e "$file: ${RED}Missing${NC}"
        exit 1
    fi
done

# Check menu scripts
echo -e "\n${YELLOW}Checking menu scripts:${NC}"
scripts=("menu" "ssh" "xray" "ws" "cert" "backup" "port" "domain")
for script in "${scripts[@]}"; do
    if [ -f "/usr/local/bin/$script" ]; then
        echo -e "$script: ${GREEN}Installed${NC}"
    else
        echo -e "$script: ${RED}Missing${NC}"
        exit 1
    fi
done

# Check ports
echo -e "\n${YELLOW}Checking ports:${NC}"
ports=("22" "80" "443")
for port in "${ports[@]}"; do
    if netstat -tuln | grep -q ":$port "; then
        echo -e "Port $port: ${GREEN}Open${NC}"
    else
        echo -e "Port $port: ${RED}Closed${NC}"
        exit 1
    fi
done

echo -e "\n${GREEN}All tests passed successfully!${NC}" 