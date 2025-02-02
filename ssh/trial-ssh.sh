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
echo -e "${CYAN}│${NC}            ${CYAN}TRIAL SSH ACCOUNT${NC}                    ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Generate random username and password
user="trial$(tr -dc 'a-z0-9' < /dev/urandom | head -c4)"
pass="$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c8)"

# Create trial account (1 day)
exp=$(date -d "+1 days" +"%Y-%m-%d")
useradd -e "$exp" -s /bin/false -M "$user"
echo -e "$pass\n$pass" | passwd "$user" &> /dev/null

# Save to database
echo "### $user $pass $exp" >> "$SSH_DB"

# Success message
clear
echo -e "${GREEN}Trial SSH Account Created Successfully${NC}"
echo -e "Username : $user"
echo -e "Password : $pass"
echo -e "Duration : 1 Day"
echo -e "Expires  : $exp" 