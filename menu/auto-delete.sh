#!/bin/bash
# Auto Delete Expired Users Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check root
if [ "${EUID}" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}   AUTO DELETE EXPIRED USERS   ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e ""

# Get current date
today=$(date +%Y-%m-%d)

# Process XRAY users
data=( `cat /etc/xray/config.json | grep '^###' | cut -d ' ' -f 2-3`);
for user in "${data[@]}"
do
    username=$(echo $user | cut -d ' ' -f 1)
    exp=$(echo $user | cut -d ' ' -f 2)
    
    if [[ $exp < $today ]]; then
        # Delete from XRAY config
        sed -i "/^### $username/,/^},{/d" /etc/xray/config.json
        sed -i "s/,,/,/g" /etc/xray/config.json
        
        echo -e "Deleted user: ${RED}$username${NC}"
        echo -e "Expired on : ${YELLOW}$exp${NC}"
    fi
done

# Restart XRAY service
systemctl restart xray

echo -e ""
echo -e "${GREEN}Auto delete completed${NC}"
echo -e "${BLUE}=============================${NC}" 