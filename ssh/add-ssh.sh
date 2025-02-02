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
echo -e "${CYAN}│${NC}            ${CYAN}CREATE SSH ACCOUNT${NC}                    ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Get user input
read -p "Username : " user
read -p "Password : " pass
read -p "Duration (days) : " duration

# Check if user exists
if grep -q "^### $user" "$SSH_DB"; then
    echo -e "${RED}Error: Username already exists${NC}"
    exit 1
fi

# Create account
exp=$(date -d "+$duration days" +"%Y-%m-%d")
useradd -e "$exp" -s /bin/false -M "$user"
echo -e "$pass\n$pass" | passwd "$user" &> /dev/null

# Save to database
echo "### $user $pass $exp" >> "$SSH_DB"

# Success message
clear
echo -e "${GREEN}SSH Account Created Successfully${NC}"
echo -e "Username : $user"
echo -e "Password : $pass"
echo -e "Duration : $duration Days"
echo -e "Expires  : $exp" 