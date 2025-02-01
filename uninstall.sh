#!/bin/bash
# Color Definitions
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

clear
echo -e "${RED}=================================================${NC}"
echo -e "${RED}║             UNINSTALLING SCRIPT                ║${NC}"
echo -e "${RED}=================================================${NC}"

# Confirm uninstallation
echo -e "${RED}WARNING! This will remove all VPN services and configurations.${NC}"
echo -e "${YELLOW}Are you absolutely sure you want to continue? (y/n)${NC}"
read -p "" confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo -e "${GREEN}Uninstallation cancelled.${NC}"
    exit 1
fi

# Stop services
echo -e "${YELLOW}Stopping services...${NC}"
systemctl stop xray
systemctl stop nginx
systemctl stop ssh
systemctl stop dropbear
systemctl stop stunnel4
systemctl stop openvpn
systemctl stop trojan-go

# Remove services
echo -e "${YELLOW}Removing services...${NC}"
systemctl disable xray
systemctl disable nginx
systemctl disable stunnel4
systemctl disable dropbear
systemctl disable openvpn
systemctl disable trojan-go

# Remove directories and files
echo -e "${YELLOW}Removing configuration files...${NC}"
rm -rf /etc/xray
rm -rf /etc/v2ray
rm -rf /etc/nginx
rm -rf /etc/stunnel
rm -rf /etc/openvpn
rm -rf /etc/trojan-go
rm -rf /var/log/xray
rm -rf /var/log/v2ray
rm -rf /var/log/nginx
rm -rf /var/log/stunnel4
rm -rf /var/log/openvpn
rm -f /etc/systemd/system/xray.service
rm -f /etc/systemd/system/v2ray.service
rm -f /etc/systemd/system/trojan-go.service

# Remove scripts
echo -e "${YELLOW}Removing script files...${NC}"
rm -f /usr/bin/menu
rm -f /usr/bin/add-ws
rm -f /usr/bin/add-ssws
rm -f /usr/bin/add-vless
rm -f /usr/bin/add-tr
rm -f /usr/bin/add-ssh
rm -f /usr/bin/update
rm -f /usr/bin/uninstall
rm -f /root/log-install.txt

# Reload systemd
systemctl daemon-reload

echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}║          UNINSTALLATION COMPLETED              ║${NC}"
echo -e "${GREEN}=================================================${NC}"
echo -e "${YELLOW}All VPN services and configurations have been removed.${NC}"
echo -e "${YELLOW}You may need to reboot your system.${NC}"
echo -e "${YELLOW}Would you like to reboot now? (y/n)${NC}"
read -p "" reboot_now

if [[ "$reboot_now" == "y" || "$reboot_now" == "Y" ]]; then
    reboot
else
    echo -e "${GREEN}Please reboot your system manually later.${NC}"
fi 