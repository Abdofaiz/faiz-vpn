#!/bin/bash
# Color Definitions
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
YELLOW='\033[1;33m'

# Get System Information
IPVPS=$(curl -s ipv4.icanhazip.com)
DOMAIN=$(cat /etc/xray/domain)
CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | xargs)
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
USED_RAM=$(free -m | awk '/^Mem:/{print $3}')
RAM_PERCENT=$(free | awk '/Mem:/ {printf("%.2f"), $3/$2*100}')
UPTIME=$(uptime -p | cut -d " " -f 2-)
if [ -f "/root/log-install.txt" ]; then
    INSTALL_DATE=$(date -r /root/log-install.txt "+%Y-%m-%d %H:%M:%S")
else
    INSTALL_DATE="Unknown"
fi

clear
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}║                  ${YELLOW}• FAIZ-VPN •                  ${GREEN}║${NC}"
echo -e "${GREEN}║              ${YELLOW}PREMIUM VPS MANAGER              ${GREEN}║${NC}"
echo -e "${GREEN}=================================================${NC}"
echo -e "${YELLOW}VPS Information${NC}"
echo -e "${GREEN}- IP VPS        :${NC} $IPVPS"
echo -e "${GREEN}- Domain        :${NC} $DOMAIN"
echo -e "${GREEN}- CPU Load      :${NC} $CPU_LOAD"
echo -e "${GREEN}- RAM Usage     :${NC} $USED_RAM MB / $TOTAL_RAM MB ($RAM_PERCENT%)"
echo -e "${GREEN}- Uptime        :${NC} $UPTIME"
echo -e "${GREEN}- Install Date  :${NC} $INSTALL_DATE"
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}║               ${YELLOW}[ Main Menu ]                   ${GREEN}║${NC}"
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}║${NC} 1${NC}. SSH & OpenVPN Account"
echo -e "${GREEN}║${NC} 2${NC}. Vmess/Vless/Xray/Trojan Account"
echo -e "${GREEN}║${NC} 3${NC}. Restart All Service"
echo -e "${GREEN}║${NC} 4${NC}. Backup & Restore"
echo -e "${GREEN}║${NC} 5${NC}. Settings"
echo -e "${GREEN}║${NC} 6${NC}. Check Service"
echo -e "${GREEN}║${NC} 7${NC}. Update Script"
echo -e "${GREEN}║${NC} 8${NC}. Uninstall Script"
echo -e "${GREEN}║${NC} 9${NC}. Exit"
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}║${NC} Mod By Abdofaiz"
echo -e "${GREEN}║${NC} Telegram: https://t.me/vpncdn"
echo -e "${GREEN}=================================================${NC}"

read -p "Select From Options [ 1 - 9 ] : " menu
echo -e ""

case $menu in
    1)
        maddssh
        ;;
    2)
        maddxray
        ;;
    3)
        sslh-fix-reboot
        ;;
    4)
        mbackup
        ;;
    5)
        msetting
        ;;
    6)
        start-menu
        ;;
    7)
        clear
        echo -e "${GREEN}Updating Script...${NC}"
        wget -q -O /usr/bin/update "https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/update.sh"
        chmod +x /usr/bin/update
        update
        echo -e "${GREEN}Update Completed${NC}"
        sleep 2
        menu
        ;;
    8)
        clear
        echo -e "${RED}Warning! This will uninstall all VPN services.${NC}"
        echo -e "${YELLOW}Are you sure you want to continue? (y/n)${NC}"
        read -p "" confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            wget -q -O /usr/bin/uninstall "https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/uninstall.sh"
            chmod +x /usr/bin/uninstall
            uninstall
        else
            menu
        fi
        ;;
    9)
        clear
        exit
        ;;
    *)
        clear
        menu
        ;;
esac
#
