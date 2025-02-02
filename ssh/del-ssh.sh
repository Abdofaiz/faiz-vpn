#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Database path
SSH_DB="/etc/ssh/.ssh.db"

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}            ${CYAN}DELETE SSH ACCOUNT${NC}                    ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# List users
echo -e "Current Users:"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ -f "$SSH_DB" ]; then
    grep "^###" "$SSH_DB" | cut -d' ' -f2 | nl -s ') '
else
    echo -e "${YELLOW}No users found${NC}"
fi
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Get username
read -p "Enter username to delete : " user

# Check if user exists
if ! grep -q "^### $user" "$SSH_DB"; then
    echo -e "${RED}Error: Username not found${NC}"
    exit 1
fi

# Delete user
userdel -f "$user"
sed -i "/^### $user/d" "$SSH_DB"

echo -e "${GREEN}User $user deleted successfully${NC}" 