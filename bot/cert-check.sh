#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}           ${CYAN}SSL CERTIFICATE CHECK${NC}                  ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Get domain
echo -ne "Enter domain to check: "
read domain

echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}Certificate Information${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if openssl is installed
if ! command -v openssl &> /dev/null; then
    echo -e "${RED}OpenSSL is not installed. Installing...${NC}"
    apt-get update && apt-get install -y openssl
fi

# Get certificate information
if cert_info=$(timeout 5 openssl s_client -connect ${domain}:443 -servername ${domain} 2>/dev/null | openssl x509 -noout -text); then
    # Extract important details
    issuer=$(echo "$cert_info" | grep "Issuer:" | sed 's/^[[:space:]]*//')
    subject=$(echo "$cert_info" | grep "Subject:" | sed 's/^[[:space:]]*//')
    dates=$(echo "$cert_info" | grep -A 2 "Validity")
    sans=$(echo "$cert_info" | grep -A 1 "Subject Alternative Name" | tail -n 1)
    
    echo -e "Domain     : ${GREEN}$domain${NC}"
    echo -e "Issuer     : ${GREEN}${issuer#*: }${NC}"
    echo -e "Subject    : ${GREEN}${subject#*: }${NC}"
    echo -e ""
    echo -e "Validity:"
    echo "$dates" | while IFS= read -r line; do
        echo -e "           ${GREEN}$line${NC}"
    done
    echo -e ""
    echo -e "SANs       : ${GREEN}${sans#*DNS:}${NC}"
    
    # Check expiration
    end_date=$(echo "$cert_info" | grep "Not After" | cut -d: -f2-)
    end_epoch=$(date -d "${end_date}" +%s)
    current_epoch=$(date +%s)
    days_left=$(( (end_epoch - current_epoch) / 86400 ))
    
    echo -e ""
    if [ $days_left -lt 30 ]; then
        echo -e "Status     : ${RED}Certificate will expire in $days_left days${NC}"
    else
        echo -e "Status     : ${GREEN}Certificate valid for $days_left days${NC}"
    fi
else
    echo -e "${RED}Failed to get certificate information for $domain${NC}"
fi

echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
menu-bot 