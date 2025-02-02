#!/bin/bash
# Test Installation Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check dependencies
check_dependency() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}$1 is not installed${NC}"
        return 1
    fi
    echo -e "${GREEN}$1 is installed${NC}"
    return 0
}

# Test system requirements
echo -e "${BLUE}Testing system requirements...${NC}"
check_dependency nginx
check_dependency certbot
check_dependency jq
check_dependency vnstat
check_dependency fail2ban

# Test ports
echo -e "\n${BLUE}Testing ports...${NC}"
ports=(22 80 443)
for port in "${ports[@]}"; do
    if netstat -tuln | grep ":$port " >/dev/null; then
        echo -e "Port $port: ${GREEN}Open${NC}"
    else
        echo -e "Port $port: ${RED}Closed${NC}"
    fi
done

# Test services
echo -e "\n${BLUE}Testing services...${NC}"
services=(nginx xray ssh)
for service in "${services[@]}"; do
    if systemctl is-active $service >/dev/null 2>&1; then
        echo -e "$service: ${GREEN}Running${NC}"
    else
        echo -e "$service: ${RED}Stopped${NC}"
    fi
done

# Test configuration files
echo -e "\n${BLUE}Testing configuration files...${NC}"
configs=("/etc/nginx/nginx.conf" "/usr/local/etc/xray/config.json" "/etc/ssh/sshd_config")
for config in "${configs[@]}"; do
    if [ -f "$config" ]; then
        echo -e "$config: ${GREEN}Exists${NC}"
    else
        echo -e "$config: ${RED}Missing${NC}"
    fi
done 