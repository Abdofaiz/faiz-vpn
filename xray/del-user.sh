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

# Config path
XRAY_CONFIG="/etc/xray/config.json"

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}             ${CYAN}DELETE XRAY USER${NC}                     ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# List users
echo -e "Current Users:"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
jq -r '.inbounds[].settings.clients[] | .email' $XRAY_CONFIG | nl -s ') '
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Get username
read -p "Enter username to delete : " user

# Delete from config
jq --arg user "$user" 'walk(
  if type == "object" and .settings.clients then
    .settings.clients |= map(select(.email != $user))
  else
    .
  end
)' $XRAY_CONFIG > /tmp/tmp.json && mv /tmp/tmp.json $XRAY_CONFIG

# Restart XRAY
systemctl restart xray

echo -e "${GREEN}User $user deleted successfully${NC}" 