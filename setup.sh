#!/bin/bash
# VPS Installation Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check root
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi

# Create installation directory
mkdir -p /usr/local/vpsmgr
cd /usr/local/vpsmgr

# Clone the repository
echo -e "${BLUE}Downloading VPS Manager...${NC}"
rm -rf /usr/local/vpsmgr/*
git clone https://github.com/Abdofaiz/faiz-vpn.git .

# Create menu directories
mkdir -p /usr/local/sbin

# Copy menu scripts
echo -e "${BLUE}Installing menu scripts...${NC}"
cd /usr/local/vpsmgr/menu
for script in *; do
    cp $script /usr/local/sbin/
    chmod +x /usr/local/sbin/$script
done

# Update PATH
echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' > /etc/environment
source /etc/environment

echo -e "${GREEN}Installation completed!${NC}" 