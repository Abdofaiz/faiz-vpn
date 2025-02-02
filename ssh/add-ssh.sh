#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Database path
SSH_DB="/etc/ssh/.ssh.db"

# Create database if not exists
if [ ! -f "$SSH_DB" ]; then
    mkdir -p /etc/ssh
    touch "$SSH_DB"
fi

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}            ${CYAN}CREATE SSH ACCOUNT${NC}                    ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Get user input
read -p "Username : " user
read -p "Password : " pass
read -p "Duration (days) : " duration

# Input validation
if [[ -z $user ]] || [[ -z $pass ]] || [[ -z $duration ]]; then
    echo -e "${RED}Error: All fields are required${NC}"
    exit 1
fi

# Check if user exists
if id -u "$user" >/dev/null 2>&1; then
    echo -e "${RED}Error: Username already exists${NC}"
    exit 1
fi

if grep -q "^### $user" "$SSH_DB"; then
    echo -e "${RED}Error: Username already exists in database${NC}"
    exit 1
fi

# Create account
exp=$(date -d "+$duration days" +"%Y-%m-%d")
useradd -e "$(date -d "$exp" +%Y-%m-%d)" -s /bin/false -M "$user"
echo "$user:$pass" | chpasswd

# Save to database
echo "### $user $pass $exp" >> "$SSH_DB"

# Success message
clear
echo -e "${GREEN}SSH Account Created Successfully${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Username : $user"
echo -e "Password : $pass"
echo -e "Duration : $duration Days"
echo -e "Expires  : $exp"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" 