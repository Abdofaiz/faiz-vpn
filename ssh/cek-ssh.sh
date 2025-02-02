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

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}            ${CYAN}CHECK SSH LOGINS${NC}                      ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo -e ""

# Get logged in users
echo -e "Currently logged in SSH users:"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
data=($(ps aux | grep -i dropbear | awk '{print $2}'))
for PID in "${data[@]}"; do
    NUM=$(cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | wc -l)
    USER=$(cat /var/log/auth.log | grep -i dropbear | grep "Password auth succeeded" | grep "dropbear\[$PID\]" | awk '{print $10}' | head -n 1)
    IP=$(cat /var/log/auth.log | grep -i dropbear | grep "Password auth succeeded" | grep "dropbear\[$PID\]" | awk '{print $12}' | head -n 1)
    if [ $NUM -eq 1 ]; then
        echo -e "$USER - $IP"
    fi
done

# OpenSSH logins
data=($(ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}'))
for PID in "${data[@]}"; do
    NUM=$(cat /var/log/auth.log | grep -i sshd | grep -i "Accepted password for" | grep "sshd\[$PID\]" | wc -l)
    USER=$(cat /var/log/auth.log | grep -i sshd | grep "Accepted password for" | grep "sshd\[$PID\]" | awk '{print $9}' | head -n 1)
    IP=$(cat /var/log/auth.log | grep -i sshd | grep "Accepted password for" | grep "sshd\[$PID\]" | awk '{print $11}' | head -n 1)
    if [ $NUM -eq 1 ]; then
        echo -e "$USER - $IP"
    fi
done
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" 