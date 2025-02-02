#!/bin/bash
# Test Installation Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to check service status
check_service() {
    local service=$1
    if systemctl is-active --quiet $service; then
        echo -e "${GREEN}$service is running${NC}"
        return 0
    else
        echo -e "${RED}$service is not running${NC}"
        return 1
    fi
}

# Function to test port
test_port() {
    local port=$1
    if netstat -tuln | grep -q ":$port "; then
        echo -e "${GREEN}Port $port is open${NC}"
        return 0
    else
        echo -e "${RED}Port $port is closed${NC}"
        return 1
    fi
}

# Test SSH
test_ssh() {
    echo -e "${BLUE}Testing SSH...${NC}"
    check_service ssh
    test_port 22
}

# Test XRAY
test_xray() {
    echo -e "${BLUE}Testing XRAY...${NC}"
    check_service xray
    test_port 443
    test_port 80

    # Test config
    if [ -f "/usr/local/etc/xray/config.json" ]; then
        echo -e "${GREEN}XRAY config exists${NC}"
        # Validate JSON
        if jq empty /usr/local/etc/xray/config.json >/dev/null 2>&1; then
            echo -e "${GREEN}XRAY config is valid JSON${NC}"
        else
            echo -e "${RED}XRAY config is invalid JSON${NC}"
        fi
    else
        echo -e "${RED}XRAY config not found${NC}"
    fi
}

# Test WebSocket
test_websocket() {
    echo -e "${BLUE}Testing WebSocket...${NC}"
    test_port 80
    test_port 443

    # Check Nginx
    check_service nginx
    if [ -f "/etc/nginx/conf.d/xray.conf" ]; then
        echo -e "${GREEN}Nginx XRAY config exists${NC}"
    else
        echo -e "${RED}Nginx XRAY config not found${NC}"
    fi
}

# Test API
test_api() {
    echo -e "${BLUE}Testing API Server...${NC}"
    check_service vps-api
    test_port 8069
}

# Test Menu
test_menu() {
    echo -e "${BLUE}Testing Menu Scripts...${NC}"
    local menu_files=(
        "/usr/local/bin/menu"
        "/usr/local/bin/ssh-manager"
        "/usr/local/bin/xray-manager"
        "/usr/local/bin/ws-manager"
    )

    for file in "${menu_files[@]}"; do
        if [ -x "$file" ]; then
            echo -e "${GREEN}$file exists and is executable${NC}"
        else
            echo -e "${RED}$file not found or not executable${NC}"
        fi
    done
}

# Main test sequence
echo -e "${BLUE}Starting System Tests${NC}"
echo "========================="

test_ssh
echo "-------------------------"
test_xray
echo "-------------------------"
test_websocket
echo "-------------------------"
test_api
echo "-------------------------"
test_menu

echo "========================="
echo -e "${BLUE}Test Complete${NC}" 