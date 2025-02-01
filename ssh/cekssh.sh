#!/bin/bash
# ==========================================
# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
YELLOW='\033[1;33m'
# ==========================================
#Getting
MYIP=$(curl -s ipv4.icanhazip.com)

clear
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}║            ${YELLOW}SSH VPN USER LOGIN               ${GREEN}║${NC}"
echo -e "${GREEN}=================================================${NC}"

# Function to count unique IPs
count_unique_ips() {
    echo "$1" | sort | uniq | wc -l
}

# Dropbear
echo -e "${YELLOW}━━━━━━━━━━[ DROPBEAR USER LOGIN ]━━━━━━━━━━${NC}"
data=( $(ps aux | grep -i dropbear | awk '{print $2}') )
echo -e "${CYAN}ID  |  Username  |  IP Address${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" > /tmp/login-db.txt
dropbear_users=0
dropbear_ips=""

for PID in "${data[@]}"
do
        cat /tmp/login-db.txt | grep "dropbear\[$PID\]" > /tmp/login-db-pid.txt;
        NUM=$(cat /tmp/login-db-pid.txt | wc -l);
        USER=$(cat /tmp/login-db-pid.txt | awk '{print $10}');
        IP=$(cat /tmp/login-db-pid.txt | awk '{print $12}');
        if [ $NUM -eq 1 ]; then
                echo -e " $PID - $USER - $IP"
                dropbear_users=$((dropbear_users + 1))
                dropbear_ips="$dropbear_ips\n$IP"
        fi
done

# OpenSSH
echo -e "\n${YELLOW}━━━━━━━━━━[ OPENSSH USER LOGIN ]━━━━━━━━━━${NC}"
echo -e "${CYAN}ID  |  Username  |  IP Address${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

cat $LOG | grep -i sshd | grep -i "Accepted password for" > /tmp/login-db.txt
data=( $(ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}') )
openssh_users=0
openssh_ips=""

for PID in "${data[@]}"
do
        cat /tmp/login-db.txt | grep "sshd\[$PID\]" > /tmp/login-db-pid.txt;
        NUM=$(cat /tmp/login-db-pid.txt | wc -l);
        USER=$(cat /tmp/login-db-pid.txt | awk '{print $9}');
        IP=$(cat /tmp/login-db-pid.txt | awk '{print $11}');
        if [ $NUM -eq 1 ]; then
                echo -e " $PID - $USER - $IP"
                openssh_users=$((openssh_users + 1))
                openssh_ips="$openssh_ips\n$IP"
        fi
done

# OpenVPN TCP
if [ -f "/etc/openvpn/server/openvpn-tcp.log" ]; then
    echo -e "\n${YELLOW}━━━━━━━━━[ OPENVPN TCP USER LOGIN ]━━━━━━━━━${NC}"
    echo -e "${CYAN}Username  |  IP Address  |  Connected Since${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    cat /etc/openvpn/server/openvpn-tcp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-tcp.txt
    cat /tmp/vpn-login-tcp.txt
    ovpn_tcp_users=$(cat /tmp/vpn-login-tcp.txt | wc -l)
    ovpn_tcp_ips=$(cat /tmp/vpn-login-tcp.txt | awk '{print $2}')
fi

# OpenVPN UDP
if [ -f "/etc/openvpn/server/openvpn-udp.log" ]; then
    echo -e "\n${YELLOW}━━━━━━━━━[ OPENVPN UDP USER LOGIN ]━━━━━━━━━${NC}"
    echo -e "${CYAN}Username  |  IP Address  |  Connected Since${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    cat /etc/openvpn/server/openvpn-udp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-udp.txt
    cat /tmp/vpn-login-udp.txt
    ovpn_udp_users=$(cat /tmp/vpn-login-udp.txt | wc -l)
    ovpn_udp_ips=$(cat /tmp/vpn-login-udp.txt | awk '{print $2}')
fi

# Summary
echo -e "\n${GREEN}━━━━━━━━━━━━[ LOGIN SUMMARY ]━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Total Dropbear Users : $dropbear_users${NC}"
echo -e "${CYAN}Total OpenSSH Users  : $openssh_users${NC}"
if [ -f "/etc/openvpn/server/openvpn-tcp.log" ]; then
    echo -e "${CYAN}Total OpenVPN TCP   : $ovpn_tcp_users${NC}"
fi
if [ -f "/etc/openvpn/server/openvpn-udp.log" ]; then
    echo -e "${CYAN}Total OpenVPN UDP   : $ovpn_udp_users${NC}"
fi

# Calculate total unique IPs
all_ips="$dropbear_ips\n$openssh_ips\n$ovpn_tcp_ips\n$ovpn_udp_ips"
unique_ips=$(echo -e "$all_ips" | grep -v '^$' | sort | uniq | wc -l)
echo -e "${CYAN}Total Unique IPs    : $unique_ips${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Cleanup
rm -f /tmp/login-db.txt
rm -f /tmp/login-db-pid.txt
rm -f /tmp/vpn-login-tcp.txt
rm -f /tmp/vpn-login-udp.txt

