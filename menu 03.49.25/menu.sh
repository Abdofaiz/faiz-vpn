#!/bin/bash
# Main Menu Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Banner
clear
echo -e "${GREEN}=====================================${NC}"
echo -e "${BLUE}        VPS Management Script         ${NC}"
echo -e "${GREEN}=====================================${NC}"

# System Information
MEMORY=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')
DISK=$(df -h | awk '$NF=="/"{printf "%s", $5}')
CPU=$(top -bn1 | grep load | awk '{printf "%.2f%%", $(NF-2)}')
echo -e "${YELLOW}CPU Usage   : $CPU${NC}"
echo -e "${YELLOW}Memory Usage: $MEMORY${NC}"
echo -e "${YELLOW}Disk Usage  : $DISK${NC}"
echo -e "${GREEN}=====================================${NC}"

# Main Menu
show_menu() {
    echo -e "\n${BLUE}=== Main Menu ===${NC}"
    echo -e "${GREEN}1)${NC} User Management"
    echo -e "${GREEN}2)${NC} Server Information"
    echo -e "${GREEN}3)${NC} Service Status"
    echo -e "${GREEN}4)${NC} Backup & Restore"
    echo -e "${GREEN}5)${NC} System Settings"
    echo -e "${RED}0)${NC} Exit"
}

# Server Information
show_server_info() {
    clear
    echo -e "${BLUE}=== Server Information ===${NC}"
    echo -e "${YELLOW}Operating System: ${NC}$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "${YELLOW}Kernel Version  : ${NC}$(uname -r)"
    echo -e "${YELLOW}IP Address      : ${NC}$(curl -s ifconfig.me)"
    echo -e "${YELLOW}CPU Model       : ${NC}$(lscpu | grep "Model name" | cut -d':' -f2 | sed 's/^[ \t]*//')"
    echo -e "${YELLOW}Total Memory    : ${NC}$(free -h | awk 'NR==2{print $2}')"
    echo -e "${YELLOW}Used Memory     : ${NC}$(free -h | awk 'NR==2{print $3}')"
    echo -e "${YELLOW}Total Disk      : ${NC}$(df -h / | awk 'NR==2{print $2}')"
    echo -e "${YELLOW}Used Disk       : ${NC}$(df -h / | awk 'NR==2{print $3}')"
}

# Service Status
show_service_status() {
    clear
    echo -e "${BLUE}=== Service Status ===${NC}"
    services=("xray" "trojan-go" "openvpn" "stunnel5" "ohp-ssh" "ohp-dropbear" "ohp-openvpn")
    
    for service in "${services[@]}"; do
        status=$(systemctl is-active $service)
        if [ "$status" == "active" ]; then
            echo -e "${service}: ${GREEN}Running${NC}"
        else
            echo -e "${service}: ${RED}Stopped${NC}"
        fi
    done
}

# System Settings
show_system_settings() {
    clear
    echo -e "${BLUE}=== System Settings ===${NC}"
    echo -e "${GREEN}1)${NC} Change SSH Port"
    echo -e "${GREEN}2)${NC} Change Timezone"
    echo -e "${GREEN}3)${NC} Update System"
    echo -e "${GREEN}4)${NC} Restart All Services"
    echo -e "${GREEN}5)${NC} Change Banner"
    echo -e "${GREEN}6)${NC} Network Speed Test"
    echo -e "${GREEN}7)${NC} Firewall Settings"
    echo -e "${GREEN}8)${NC} Change Domain"
    echo -e "${GREEN}9)${NC} Memory/Swap Settings"
    echo -e "${GREEN}10)${NC} Change DNS Settings"
    echo -e "${GREEN}11)${NC} BBR Settings"
    echo -e "${GREEN}12)${NC} Port Scanner"
    echo -e "${GREEN}13)${NC} System Cleanup"
    echo -e "${GREEN}14)${NC} SSL Certificate Manager"
    echo -e "${GREEN}15)${NC} Network Tweaks"
    echo -e "${GREEN}16)${NC} Security Settings"
    echo -e "${GREEN}17)${NC} Bandwidth Monitor"
    echo -e "${GREEN}18)${NC} Service Ports Manager"
    echo -e "${GREEN}19)${NC} Backup Schedule"
    echo -e "${GREEN}20)${NC} Traffic Monitor"
    echo -e "${GREEN}21)${NC} Anti-DDoS Settings"
    echo -e "${GREEN}22)${NC} Multi-login Limiter"
    echo -e "${GREEN}23)${NC} Auto-Kill Multi-login"
    echo -e "${GREEN}24)${NC} Connection Monitor"
    echo -e "${GREEN}0)${NC} Back to Main Menu"
    
    read -p "Select option: " setting_choice
    case $setting_choice in
        1) change_ssh_port ;;
        2) change_timezone ;;
        3) update_system ;;
        4) restart_services ;;
        5) change_banner ;;
        6) speed_test ;;
        7) firewall_settings ;;
        8) change_domain ;;
        9) memory_settings ;;
        10) change_dns ;;
        11) bbr_settings ;;
        12) port_scanner ;;
        13) system_cleanup ;;
        14) ssl_manager ;;
        15) network_tweaks ;;
        16) security_settings ;;
        17) bandwidth_monitor ;;
        18) port_manager ;;
        19) backup_scheduler ;;
        20) traffic_monitor ;;
        21) ddos_settings ;;
        22) multilogin_limiter ;;
        23) autokill_multilogin ;;
        24) connection_monitor ;;
        0) return ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
}

# Change SSH Port
change_ssh_port() {
    clear
    echo -e "${BLUE}=== Change SSH Port ===${NC}"
    current_port=$(grep -E "^Port" /etc/ssh/sshd_config | cut -d' ' -f2)
    echo -e "Current SSH Port: ${GREEN}$current_port${NC}"
    read -p "Enter new SSH port (1-65535): " new_port
    
    # Validate port number
    if [[ ! "$new_port" =~ ^[0-9]+$ ]] || [ "$new_port" -lt 1 ] || [ "$new_port" -gt 65535 ]; then
        echo -e "${RED}Invalid port number!${NC}"
        return 1
    fi
    
    # Update SSH config
    sed -i "s/^Port .*/Port $new_port/" /etc/ssh/sshd_config
    systemctl restart sshd
    echo -e "${GREEN}SSH port changed to $new_port${NC}"
}

# Change Timezone
change_timezone() {
    clear
    echo -e "${BLUE}=== Change Timezone ===${NC}"
    current_tz=$(timedatectl | grep "Time zone" | awk '{print $3}')
    echo -e "Current Timezone: ${GREEN}$current_tz${NC}"
    
    # List common timezones
    echo -e "\nCommon Timezones:"
    echo -e "1) Asia/Manila"
    echo -e "2) Asia/Singapore"
    echo -e "3) Asia/Tokyo"
    echo -e "4) Asia/Jakarta"
    echo -e "5) Custom"
    
    read -p "Select timezone (1-5): " tz_choice
    case $tz_choice in
        1) TZ="Asia/Manila" ;;
        2) TZ="Asia/Singapore" ;;
        3) TZ="Asia/Tokyo" ;;
        4) TZ="Asia/Jakarta" ;;
        5) 
            read -p "Enter timezone (e.g., Asia/Bangkok): " TZ
            ;;
        *) 
            echo -e "${RED}Invalid choice${NC}"
            return 1
            ;;
    esac
    
    timedatectl set-timezone $TZ
    echo -e "${GREEN}Timezone changed to $TZ${NC}"
}

# Update System
update_system() {
    clear
    echo -e "${BLUE}=== System Update ===${NC}"
    echo -e "Updating system packages..."
    apt update
    apt upgrade -y
    apt autoremove -y
    echo -e "${GREEN}System update completed${NC}"
}

# Restart All Services
restart_services() {
    clear
    echo -e "${BLUE}=== Restarting Services ===${NC}"
    services=("xray" "trojan-go" "openvpn" "stunnel5" "ohp-ssh" "ohp-dropbear" "ohp-openvpn" "ssh" "dropbear")
    
    for service in "${services[@]}"; do
        echo -e "Restarting $service..."
        systemctl restart $service
    done
    echo -e "${GREEN}All services restarted${NC}"
}

# Change SSH Banner
change_banner() {
    clear
    echo -e "${BLUE}=== Change SSH Banner ===${NC}"
    echo -e "Current banner:"
    if [ -f /etc/issue.net ]; then
        cat /etc/issue.net
    fi
    
    echo -e "\nEnter new banner text (Ctrl+D when done):"
    cat > /etc/issue.net
    sed -i 's/#Banner none/Banner \/etc\/issue.net/g' /etc/ssh/sshd_config
    systemctl restart sshd
    echo -e "${GREEN}Banner updated successfully${NC}"
}

# Network Speed Test
speed_test() {
    clear
    echo -e "${BLUE}=== Network Speed Test ===${NC}"
    echo -e "Installing speedtest-cli if not present..."
    apt install -y python3-pip &>/dev/null
    pip3 install speedtest-cli &>/dev/null
    
    echo -e "Testing network speed..."
    speedtest-cli --simple
}

# Firewall Settings
firewall_settings() {
    clear
    echo -e "${BLUE}=== Firewall Settings ===${NC}"
    echo -e "1) Show Current Rules"
    echo -e "2) Allow Port"
    echo -e "3) Block Port"
    echo -e "4) Enable Firewall"
    echo -e "5) Disable Firewall"
    echo -e "0) Back"
    
    read -p "Select option: " fw_choice
    case $fw_choice in
        1) iptables -L -n ;;
        2) 
            read -p "Enter port to allow: " port
            iptables -A INPUT -p tcp --dport $port -j ACCEPT
            iptables -A INPUT -p udp --dport $port -j ACCEPT
            iptables-save > /etc/iptables/rules.v4
            ;;
        3)
            read -p "Enter port to block: " port
            iptables -A INPUT -p tcp --dport $port -j DROP
            iptables -A INPUT -p udp --dport $port -j DROP
            iptables-save > /etc/iptables/rules.v4
            ;;
        4) 
            ufw enable
            echo -e "${GREEN}Firewall enabled${NC}"
            ;;
        5)
            ufw disable
            echo -e "${YELLOW}Firewall disabled${NC}"
            ;;
        0) return ;;
    esac
}

# Change Domain
change_domain() {
    clear
    echo -e "${BLUE}=== Change Domain Settings ===${NC}"
    echo -e "Current domain settings:"
    if [ -f /usr/local/etc/xray/domain.txt ]; then
        cat /usr/local/etc/xray/domain.txt
    fi
    
    read -p "Enter new domain: " new_domain
    echo "$new_domain" > /usr/local/etc/xray/domain.txt
    
    # Update certificates
    echo -e "Updating SSL certificates..."
    mkdir -p /usr/local/etc/xray
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /usr/local/etc/xray/xray.key \
        -out /usr/local/etc/xray/xray.crt \
        -subj "/CN=$new_domain"
    
    # Restart services
    systemctl restart xray
    systemctl restart trojan-go
    echo -e "${GREEN}Domain updated successfully${NC}"
}

# Memory/Swap Settings
memory_settings() {
    clear
    echo -e "${BLUE}=== Memory/Swap Settings ===${NC}"
    echo -e "Current Memory Usage:"
    free -h
    echo -e "\n1) Add Swap"
    echo -e "2) Remove Swap"
    echo -e "3) Clear RAM Cache"
    echo -e "0) Back"
    
    read -p "Select option: " mem_choice
    case $mem_choice in
        1)
            read -p "Enter swap size in GB: " swap_size
            dd if=/dev/zero of=/swapfile bs=1G count=$swap_size
            chmod 600 /swapfile
            mkswap /swapfile
            swapon /swapfile
            echo '/swapfile none swap sw 0 0' >> /etc/fstab
            echo -e "${GREEN}Swap added successfully${NC}"
            ;;
        2)
            swapoff -a
            rm -f /swapfile
            sed -i '/swapfile/d' /etc/fstab
            echo -e "${GREEN}Swap removed successfully${NC}"
            ;;
        3)
            sync; echo 3 > /proc/sys/vm/drop_caches
            echo -e "${GREEN}RAM cache cleared${NC}"
            ;;
        0) return ;;
    esac
}

# DNS Settings
change_dns() {
    clear
    echo -e "${BLUE}=== DNS Settings ===${NC}"
    echo -e "Current DNS servers:"
    cat /etc/resolv.conf | grep nameserver
    
    echo -e "\n1) Google DNS"
    echo -e "2) Cloudflare DNS"
    echo -e "3) Custom DNS"
    echo -e "0) Back"
    
    read -p "Select option: " dns_choice
    case $dns_choice in
        1)
            echo "nameserver 8.8.8.8" > /etc/resolv.conf
            echo "nameserver 8.8.4.4" >> /etc/resolv.conf
            ;;
        2)
            echo "nameserver 1.1.1.1" > /etc/resolv.conf
            echo "nameserver 1.0.0.1" >> /etc/resolv.conf
            ;;
        3)
            read -p "Enter primary DNS: " dns1
            read -p "Enter secondary DNS: " dns2
            echo "nameserver $dns1" > /etc/resolv.conf
            echo "nameserver $dns2" >> /etc/resolv.conf
            ;;
        0) return ;;
    esac
    echo -e "${GREEN}DNS settings updated${NC}"
}

# BBR Settings
bbr_settings() {
    clear
    echo -e "${BLUE}=== BBR Settings ===${NC}"
    echo -e "Current BBR status:"
    sysctl net.ipv4.tcp_congestion_control
    
    echo -e "\n1) Enable BBR"
    echo -e "2) Disable BBR"
    echo -e "3) Check BBR Status"
    echo -e "0) Back"
    
    read -p "Select option: " bbr_choice
    case $bbr_choice in
        1)
            echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
            echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
            sysctl -p
            echo -e "${GREEN}BBR enabled${NC}"
            ;;
        2)
            sed -i '/net.core.default_qdisc=fq/d' /etc/sysctl.conf
            sed -i '/net.ipv4.tcp_congestion_control=bbr/d' /etc/sysctl.conf
            sysctl -p
            echo -e "${GREEN}BBR disabled${NC}"
            ;;
        3)
            echo -e "TCP Congestion Control: $(sysctl net.ipv4.tcp_congestion_control)"
            echo -e "Queue Discipline: $(sysctl net.core.default_qdisc)"
            ;;
        0) return ;;
    esac
}

# Port Scanner
port_scanner() {
    clear
    echo -e "${BLUE}=== Port Scanner ===${NC}"
    echo -e "1) Scan All Open Ports"
    echo -e "2) Scan Specific Port"
    echo -e "0) Back"
    
    read -p "Select option: " scan_choice
    case $scan_choice in
        1)
            echo -e "Scanning all open ports..."
            netstat -tulpn | grep LISTEN
            ;;
        2)
            read -p "Enter port to scan: " port
            nc -zv localhost $port 2>&1
            ;;
        0) return ;;
    esac
}

# System Cleanup
system_cleanup() {
    clear
    echo -e "${BLUE}=== System Cleanup ===${NC}"
    echo -e "1) Clean Package Cache"
    echo -e "2) Remove Old Kernels"
    echo -e "3) Clean Log Files"
    echo -e "4) Clean Temp Files"
    echo -e "5) Clean All"
    echo -e "0) Back"
    
    read -p "Select option: " clean_choice
    case $clean_choice in
        1)
            apt-get clean
            apt-get autoclean
            echo -e "${GREEN}Package cache cleaned${NC}"
            ;;
        2)
            apt-get autoremove --purge
            echo -e "${GREEN}Old kernels removed${NC}"
            ;;
        3)
            find /var/log -type f -delete
            echo -e "${GREEN}Log files cleaned${NC}"
            ;;
        4)
            rm -rf /tmp/*
            echo -e "${GREEN}Temp files cleaned${NC}"
            ;;
        5)
            apt-get clean
            apt-get autoclean
            apt-get autoremove --purge
            find /var/log -type f -delete
            rm -rf /tmp/*
            echo -e "${GREEN}System cleaned${NC}"
            ;;
        0) return ;;
    esac
}

# SSL Certificate Manager
ssl_manager() {
    clear
    echo -e "${BLUE}=== SSL Certificate Manager ===${NC}"
    echo -e "1) View Current Certificates"
    echo -e "2) Generate Self-Signed Certificate"
    echo -e "3) Install Let's Encrypt Certificate"
    echo -e "4) Renew Certificates"
    echo -e "0) Back"
    
    read -p "Select option: " ssl_choice
    case $ssl_choice in
        1)
            echo -e "Current certificates in /usr/local/etc/xray/:"
            ls -l /usr/local/etc/xray/*.crt
            ls -l /usr/local/etc/xray/*.key
            ;;
        2)
            read -p "Enter domain name: " domain
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout /usr/local/etc/xray/xray.key \
                -out /usr/local/etc/xray/xray.crt \
                -subj "/CN=$domain"
            echo -e "${GREEN}Self-signed certificate generated${NC}"
            ;;
        3)
            apt install -y certbot
            read -p "Enter domain name: " domain
            certbot certonly --standalone -d $domain
            cp /etc/letsencrypt/live/$domain/fullchain.pem /usr/local/etc/xray/xray.crt
            cp /etc/letsencrypt/live/$domain/privkey.pem /usr/local/etc/xray/xray.key
            echo -e "${GREEN}Let's Encrypt certificate installed${NC}"
            ;;
        4)
            certbot renew
            echo -e "${GREEN}Certificates renewed${NC}"
            ;;
        0) return ;;
    esac
}

# Network Tweaks
network_tweaks() {
    clear
    echo -e "${BLUE}=== Network Tweaks ===${NC}"
    echo -e "1) Optimize TCP Settings"
    echo -e "2) Enable IPv6"
    echo -e "3) Disable IPv6"
    echo -e "4) Set MTU Size"
    echo -e "5) Show Network Stats"
    echo -e "0) Back"
    
    read -p "Select option: " net_choice
    case $net_choice in
        1)
            # Optimize TCP settings
            cat > /etc/sysctl.d/99-network-tune.conf <<EOF
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
EOF
            sysctl -p /etc/sysctl.d/99-network-tune.conf
            echo -e "${GREEN}TCP settings optimized${NC}"
            ;;
        2)
            sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
            sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
            sysctl -p
            echo -e "${GREEN}IPv6 enabled${NC}"
            ;;
        3)
            echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
            echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
            sysctl -p
            echo -e "${GREEN}IPv6 disabled${NC}"
            ;;
        4)
            read -p "Enter MTU size (default 1500): " mtu_size
            ip link set dev $(ip route get 8.8.8.8 | awk '{print $5}') mtu $mtu_size
            echo -e "${GREEN}MTU size updated${NC}"
            ;;
        5)
            echo -e "Network Statistics:"
            echo -e "==================="
            netstat -s | head -n 20
            ;;
        0) return ;;
    esac
}

# Security Settings
security_settings() {
    clear
    echo -e "${BLUE}=== Security Settings ===${NC}"
    echo -e "1) Configure Fail2Ban"
    echo -e "2) Change SSH Security"
    echo -e "3) Enable/Disable Root Login"
    echo -e "4) Show Login History"
    echo -e "5) Block Country IP"
    echo -e "0) Back"
    
    read -p "Select option: " sec_choice
    case $sec_choice in
        1)
            apt install -y fail2ban
            cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
            systemctl restart fail2ban
            echo -e "${GREEN}Fail2Ban configured${NC}"
            ;;
        2)
            sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
            sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
            systemctl restart sshd
            echo -e "${GREEN}SSH security enhanced${NC}"
            ;;
        3)
            read -p "Enable root login? (y/n): " root_login
            if [[ "$root_login" == "y" ]]; then
                sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
            else
                sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
            fi
            systemctl restart sshd
            echo -e "${GREEN}Root login settings updated${NC}"
            ;;
        4)
            last | head -n 20
            ;;
        5)
            read -p "Enter country code to block (e.g., CN): " country
            apt install -y ipset
            wget -O /usr/local/bin/blockCountry.sh "https://raw.githubusercontent.com/trick77/ipset-country/master/ipset-country.sh"
            chmod +x /usr/local/bin/blockCountry.sh
            /usr/local/bin/blockCountry.sh $country
            echo -e "${GREEN}Country IPs blocked${NC}"
            ;;
        0) return ;;
    esac
}

# Bandwidth Monitor
bandwidth_monitor() {
    clear
    echo -e "${BLUE}=== Bandwidth Monitor ===${NC}"
    echo -e "1) Show Current Usage"
    echo -e "2) Show Top Connections"
    echo -e "3) Monitor Real-time Traffic"
    echo -e "0) Back"
    
    read -p "Select option: " bw_choice
    case $bw_choice in
        1)
            vnstat -h
            ;;
        2)
            echo -e "Top 10 connections:"
            netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -n 10
            ;;
        3)
            iftop -n
            ;;
        0) return ;;
    esac
}

# Service Ports Manager
port_manager() {
    clear
    echo -e "${BLUE}=== Service Ports Manager ===${NC}"
    echo -e "1) Show All Service Ports"
    echo -e "2) Change XRAY Ports"
    echo -e "3) Change OpenVPN Ports"
    echo -e "4) Change Stunnel Ports"
    echo -e "0) Back"
    
    read -p "Select option: " port_choice
    case $port_choice in
        1)
            echo -e "Current Service Ports:"
            echo -e "====================="
            netstat -tulpn | grep LISTEN
            ;;
        2)
            read -p "Enter new XRAY port: " xray_port
            sed -i "s/\"port\": [0-9]*/\"port\": $xray_port/" /usr/local/etc/xray/config.json
            systemctl restart xray
            echo -e "${GREEN}XRAY port updated${NC}"
            ;;
        3)
            read -p "Enter new OpenVPN TCP port: " ovpn_tcp
            sed -i "s/port [0-9]*/port $ovpn_tcp/" /etc/openvpn/server/server.conf
            systemctl restart openvpn-server@server
            echo -e "${GREEN}OpenVPN port updated${NC}"
            ;;
        4)
            read -p "Enter new Stunnel port: " stunnel_port
            sed -i "s/accept = [0-9]*/accept = $stunnel_port/" /etc/stunnel5/stunnel5.conf
            systemctl restart stunnel5
            echo -e "${GREEN}Stunnel port updated${NC}"
            ;;
        0) return ;;
    esac
}

# Backup Schedule Manager
backup_scheduler() {
    clear
    echo -e "${BLUE}=== Backup Schedule Manager ===${NC}"
    echo -e "1) Show Current Schedule"
    echo -e "2) Set Daily Backup"
    echo -e "3) Set Weekly Backup"
    echo -e "4) Disable Backup Schedule"
    echo -e "0) Back"
    
    read -p "Select option: " bak_choice
    case $bak_choice in
        1)
            crontab -l | grep backup-vps
            ;;
        2)
            echo "0 0 * * * /usr/local/bin/backup-vps" >> /etc/crontab
            echo -e "${GREEN}Daily backup scheduled${NC}"
            ;;
        3)
            echo "0 0 * * 0 /usr/local/bin/backup-vps" >> /etc/crontab
            echo -e "${GREEN}Weekly backup scheduled${NC}"
            ;;
        4)
            sed -i '/backup-vps/d' /etc/crontab
            echo -e "${GREEN}Backup schedule disabled${NC}"
            ;;
        0) return ;;
    esac
}

# Traffic Monitor
traffic_monitor() {
    clear
    echo -e "${BLUE}=== Traffic Monitor ===${NC}"
    echo -e "1) Install NetData"
    echo -e "2) Install Grafana"
    echo -e "3) Show Live Bandwidth"
    echo -e "4) Show Connection Stats"
    echo -e "0) Back"
    
    read -p "Select option: " tm_choice
    case $tm_choice in
        1)
            bash <(curl -Ss https://my-netdata.io/kickstart.sh)
            echo -e "${GREEN}NetData installed. Access at http://your-ip:19999${NC}"
            ;;
        2)
            apt-get install -y apt-transport-https software-properties-common
            wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
            echo "deb https://packages.grafana.com/oss/deb stable main" > /etc/apt/sources.list.d/grafana.list
            apt-get update
            apt-get install -y grafana
            systemctl enable grafana-server
            systemctl start grafana-server
            echo -e "${GREEN}Grafana installed. Access at http://your-ip:3000${NC}"
            ;;
        3)
            echo -e "Press Ctrl+C to stop"
            vnstat -l
            ;;
        4)
            netstat -an | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n
            ;;
        0) return ;;
    esac
}

# Anti-DDoS Settings
ddos_settings() {
    clear
    echo -e "${BLUE}=== Anti-DDoS Settings ===${NC}"
    echo -e "1) Install DDoS Deflate"
    echo -e "2) Configure Connection Limits"
    echo -e "3) Blacklist IP"
    echo -e "4) Show Blocked IPs"
    echo -e "0) Back"
    
    read -p "Select option: " ddos_choice
    case $ddos_choice in
        1)
            wget https://github.com/jgmdev/ddos-deflate/archive/master.zip
            unzip master.zip
            cd ddos-deflate-master
            ./install.sh
            echo -e "${GREEN}DDoS Deflate installed${NC}"
            ;;
        2)
            echo -e "Setting connection limits..."
            cat > /etc/security/limits.conf <<EOF
* soft nofile 51200
* hard nofile 51200
root soft nofile 51200
root hard nofile 51200
EOF
            sysctl -p
            echo -e "${GREEN}Connection limits configured${NC}"
            ;;
        3)
            read -p "Enter IP to blacklist: " ip
            iptables -A INPUT -s $ip -j DROP
            echo -e "${GREEN}IP $ip has been blacklisted${NC}"
            ;;
        4)
            iptables -L INPUT -n -v | grep DROP
            ;;
        0) return ;;
    esac
}

# Multi-login Limiter
multilogin_limiter() {
    clear
    echo -e "${BLUE}=== Multi-login Limiter ===${NC}"
    echo -e "1) Set Max Login Limit"
    echo -e "2) Show Current Limits"
    echo -e "3) Reset Limits"
    echo -e "0) Back"
    
    read -p "Select option: " ml_choice
    case $ml_choice in
        1)
            read -p "Enter max login limit: " max_login
            cat > /usr/local/bin/limit-login <<EOF
#!/bin/bash
if [ \$(who | grep -c $USER) -gt $max_login ]; then
    pkill -u $USER
fi
EOF
            chmod +x /usr/local/bin/limit-login
            echo "*/1 * * * * root /usr/local/bin/limit-login" >> /etc/crontab
            echo -e "${GREEN}Login limit set to $max_login${NC}"
            ;;
        2)
            if [ -f /usr/local/bin/limit-login ]; then
                cat /usr/local/bin/limit-login
            else
                echo -e "${RED}No limit configured${NC}"
            fi
            ;;
        3)
            rm -f /usr/local/bin/limit-login
            sed -i '/limit-login/d' /etc/crontab
            echo -e "${GREEN}Login limits reset${NC}"
            ;;
        0) return ;;
    esac
}

# Auto-Kill Multi-login
autokill_multilogin() {
    clear
    echo -e "${BLUE}=== Auto-Kill Multi-login ===${NC}"
    echo -e "1) Enable Auto-Kill"
    echo -e "2) Disable Auto-Kill"
    echo -e "3) Set Kill Interval"
    echo -e "0) Back"
    
    read -p "Select option: " ak_choice
    case $ak_choice in
        1)
            cat > /usr/local/bin/autokill <<EOF
#!/bin/bash
user=\$(ps aux | grep -w [p]roc_open | awk '{print \$2}')
kill \$user
EOF
            chmod +x /usr/local/bin/autokill
            echo "*/5 * * * * root /usr/local/bin/autokill" >> /etc/crontab
            echo -e "${GREEN}Auto-Kill enabled${NC}"
            ;;
        2)
            rm -f /usr/local/bin/autokill
            sed -i '/autokill/d' /etc/crontab
            echo -e "${GREEN}Auto-Kill disabled${NC}"
            ;;
        3)
            read -p "Enter interval in minutes: " interval
            sed -i "s/\*\/[0-9]*/\*\/$interval/" /etc/crontab
            echo -e "${GREEN}Kill interval set to $interval minutes${NC}"
            ;;
        0) return ;;
    esac
}

# Connection Monitor
connection_monitor() {
    clear
    echo -e "${BLUE}=== Connection Monitor ===${NC}"
    echo -e "1) Show Active Connections"
    echo -e "2) Show Connection History"
    echo -e "3) Monitor Real-time Connections"
    echo -e "4) Export Connection Logs"
    echo -e "0) Back"
    
    read -p "Select option: " cm_choice
    case $cm_choice in
        1)
            echo -e "Active SSH Connections:"
            who
            echo -e "\nActive OpenVPN Connections:"
            cat /etc/openvpn/server/openvpn-status.log 2>/dev/null
            ;;
        2)
            echo -e "Connection History:"
            last | head -n 20
            ;;
        3)
            echo -e "Press Ctrl+C to stop"
            watch -n 1 netstat -anp | grep ESTABLISHED
            ;;
        4)
            log_file="/root/connection_log_$(date +%Y%m%d).txt"
            who > $log_file
            last >> $log_file
            echo -e "${GREEN}Logs exported to $log_file${NC}"
            ;;
        0) return ;;
    esac
}

# Main Loop
while true; do
    show_menu
    read -p "Select option: " choice
    case $choice in
        1) source /usr/local/bin/user-management.sh ;;
        2) show_server_info ;;
        3) show_service_status ;;
        4) source /usr/local/bin/backup-vps ;;
        5) show_system_settings ;;
        0) clear; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -p "Press enter to continue..."
done 