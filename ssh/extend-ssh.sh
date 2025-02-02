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

# Database path
SSH_DB="/etc/ssh/.ssh.db"

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}            ${CYAN}EXTEND SSH ACCOUNT${NC}                    ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# List users
echo -e "Current Users:"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
grep "^###" "$SSH_DB" | while read line; do
    user=$(echo $line | cut -d' ' -f2)
    exp=$(echo $line | cut -d' ' -f4)
    printf "%-4s %-20s %s\n" ")" "$user" "$exp"
done | nl
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Get user input
read -p "Username to extend : " user
read -p "Duration (days) : " duration

# Check if user exists
if ! grep -q "^### $user" "$SSH_DB"; then
    echo -e "${RED}Error: Username not found${NC}"
    exit 1
fi

# Calculate new expiry
exp=$(date -d "+$duration days" +"%Y-%m-%d")
chage -E "$exp" "$user"

# Update database
sed -i "s/^### $user .*/### $user $(grep "^### $user" "$SSH_DB" | cut -d' ' -f3) $exp/" "$SSH_DB"

echo -e "${GREEN}Account $user extended successfully${NC}"
echo -e "New expiry: $exp" 