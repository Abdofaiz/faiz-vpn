#!/bin/bash
# XRAY Updater Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Version to install
XRAY_VERSION="1.8.4"

update_xray() {
    echo -e "${BLUE}Updating XRAY Core to v${XRAY_VERSION}...${NC}"
    
    # Stop XRAY service
    systemctl stop xray
    
    # Backup current config
    cp /usr/local/etc/xray/config.json /usr/local/etc/xray/config.json.backup
    
    # Download and install new version
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root --version ${XRAY_VERSION}
    
    # Restore config
    cp /usr/local/etc/xray/config.json.backup /usr/local/etc/xray/config.json
    
    # Restart service
    systemctl restart xray
    
    # Check status
    if systemctl is-active --quiet xray; then
        echo -e "${GREEN}XRAY Core updated successfully to v${XRAY_VERSION}${NC}"
    else
        echo -e "${RED}Update failed! Restoring backup...${NC}"
        cp /usr/local/etc/xray/config.json.backup /usr/local/etc/xray/config.json
        systemctl restart xray
    fi
}

# Run update
update_xray 