#!/bin/bash
# Advanced Menu Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Show menu
show_menu() {
    clear
    echo -e "${BLUE}=============================${NC}"
    echo -e "${YELLOW}     ADVANCED MENU     ${NC}"
    echo -e "${BLUE}=============================${NC}"
    echo -e ""
    echo -e "${GREEN}1${NC}. Service Manager"
    echo -e "${GREEN}2${NC}. Port Manager"
    echo -e "${GREEN}3${NC}. Security Settings"
    echo -e "${GREEN}4${NC}. Backup Manager"
    echo -e "${GREEN}5${NC}. System Monitor"
    echo -e "${GREEN}6${NC}. Network Tools"
    echo -e "${GREEN}0${NC}. Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}=============================${NC}"
}

# Service manager
service_manager() {
    clear
    echo -e "${BLUE}=== Service Manager ===${NC}"
    echo -e "1. Start Service"
    echo -e "2. Stop Service"
    echo -e "3. Restart Service"
    echo -e "4. View Status"
    read -p "Select option: " choice
    
    case $choice in
        1|2|3|4)
            read -p "Enter service name: " service
            case $choice in
                1) systemctl start $service ;;
                2) systemctl stop $service ;;
                3) systemctl restart $service ;;
                4) systemctl status $service ;;
            esac
            ;;
    esac
}

# Port manager
port_manager() {
    clear
    echo -e "${BLUE}=== Port Manager ===${NC}"
    echo -e "1. View Open Ports"
    echo -e "2. Change Port"
    echo -e "3. Block Port"
    echo -e "4. Unblock Port"
    read -p "Select option: " choice
    
    case $choice in
        1) netstat -tulpn ;;
        2) 
            read -p "Service (ssh/xray/nginx): " service
            read -p "New port: " port
            # Port change logic here
            ;;
        3|4)
            read -p "Enter port to block/unblock: " port
            if [ $choice -eq 3 ]; then
                iptables -A INPUT -p tcp --dport $port -j DROP
            else
                iptables -D INPUT -p tcp --dport $port -j DROP
            fi
            ;;
    esac
}

# Security settings
security_settings() {
    clear
    echo -e "${BLUE}=== Security Settings ===${NC}"
    echo -e "1. Configure Fail2Ban"
    echo -e "2. Update SSL Certificate"
    echo -e "3. Change SSH Config"
    echo -e "4. View Security Logs"
    read -p "Select option: " choice
    
    case $choice in
        1) nano /etc/fail2ban/jail.local ;;
        2) certbot renew ;;
        3) nano /etc/ssh/sshd_config ;;
        4) tail -f /var/log/auth.log ;;
    esac
}

# Backup manager
backup_manager() {
    clear
    echo -e "${BLUE}=== Backup Manager ===${NC}"
    echo -e "1. Create Backup"
    echo -e "2. Restore Backup"
    echo -e "3. Schedule Backup"
    echo -e "4. View Backups"
    read -p "Select option: " choice
    
    case $choice in
        1) 
            date=$(date +%Y%m%d)
            tar -czf backup-$date.tar.gz /etc/xray /usr/local/etc/xray
            echo -e "${GREEN}Backup created: backup-$date.tar.gz${NC}"
            ;;
        2)
            read -p "Enter backup file: " file
            tar -xzf $file -C /
            echo -e "${GREEN}Backup restored${NC}"
            ;;
        3)
            echo "0 0 * * * root tar -czf /root/backup-\$(date +\%Y\%m\%d).tar.gz /etc/xray" >> /etc/crontab
            echo -e "${GREEN}Daily backup scheduled${NC}"
            ;;
        4)
            ls -l backup-*.tar.gz 2>/dev/null || echo "No backups found"
            ;;
    esac
}

# System monitor
system_monitor() {
    clear
    echo -e "${BLUE}=== System Monitor ===${NC}"
    echo -e "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%"
    echo -e "Memory Usage: $(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}')"
    echo -e "Disk Usage: $(df -h / | awk 'NR==2{print $5}')"
    echo -e "\nActive Connections:"
    netstat -an | grep ESTABLISHED | wc -l
}

# Network tools
network_tools() {
    clear
    echo -e "${BLUE}=== Network Tools ===${NC}"
    echo -e "1. Speed Test"
    echo -e "2. Network Stats"
    echo -e "3. DNS Lookup"
    echo -e "4. Trace Route"
    read -p "Select option: " choice
    
    case $choice in
        1) speedtest-cli ;;
        2) vnstat ;;
        3)
            read -p "Enter domain: " domain
            dig $domain
            ;;
        4)
            read -p "Enter host: " host
            traceroute $host
            ;;
    esac
}

# Main loop
while true; do
    show_menu
    read -p "Select option: " choice
    case $choice in
        1) service_manager ;;
        2) port_manager ;;
        3) security_settings ;;
        4) backup_manager ;;
        5) system_monitor ;;
        6) network_tools ;;
        0) break ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -n 1 -s -r -p "Press any key to continue"
done 