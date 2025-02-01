#!/bin/bash

# Check if root
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi

# Check virtualization
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi

# OS version check
check_os_support() {
		source /etc/os-release
		OS_NAME=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
		OS_VERSION=$(echo "$VERSION_ID")
		OS_VERSION_ID=$(echo "$VERSION_ID" | cut -d. -f1)

		case ${OS_NAME} in
				ubuntu)
						if [[ "${OS_VERSION_ID}" -lt 18 ]] || [[ "${OS_VERSION_ID}" -gt 24 ]]; then
								echo "This script only supports Ubuntu versions 18.04, 20.04, 22.04, and 24.04"
								exit 1
						fi
						;;
				debian)
						if [[ "${OS_VERSION_ID}" -lt 10 ]] || [[ "${OS_VERSION_ID}" -gt 12 ]]; then
								echo "This script only supports Debian versions 10, 11, and 12"
								exit 1
						fi
						;;
				*)
						echo "This script only supports Ubuntu and Debian systems"
						exit 1
						;;
		esac

		echo "OS: ${OS_NAME^} ${OS_VERSION} is supported"
}

# System requirements check
check_system_requirements() {
		# Check minimum RAM (2GB)
		total_ram=$(free -m | awk '/^Mem:/{print $2}')
		if [ $total_ram -lt 2048 ]; then
				echo "Minimum 2GB RAM required. Your system has ${total_ram}MB"
				exit 1
		fi

		# Check minimum disk space (20GB)
		total_disk=$(df -BG / | awk 'NR==2 {print $4}' | cut -d'G' -f1)
		if [ $total_disk -lt 20 ]; then
				echo "Minimum 20GB free disk space required. Your system has ${total_disk}GB"
				exit 1
		fi
}

# Package manager update function
update_system() {
		case ${OS_NAME} in
				ubuntu|debian)
						apt update -y
						apt upgrade -y
						apt install -y wget curl git unzip tar net-tools
						;;
		esac
}

# Main installation function
main_install() {
		# Your existing installation code here
		if [ -f "/etc/xray/domain" ]; then
				echo "Script Already Installed"
				exit 0
		fi

		mkdir -p /var/lib/Abdofaizvpn

		# Download and execute components
		download_and_execute "${sshlink}" "newhost.sh"
		sleep 1
		download_and_execute "${xraylink}" "ins-xray.sh"
		download_and_execute "${sshlink}" "ssh-vpn.sh"
		download_and_execute "${websocketlink}" "edu.sh"
		download_and_execute "${ohplink}" "ohp.sh"
		download_and_execute "${backuplink}" "set-br.sh"
		download_and_execute "${updatelink}" "getupdate.sh"
		download_and_execute "${sslhlink}" "sslh-fix.sh"
}

# Download and execute helper
download_and_execute() {
		local url="https://${1}/${2}"
		local file="${2}"
		echo "Downloading ${file}..."
		if ! wget "$url" -q --show-progress; then
				echo -e "${RED}Failed to download ${file}${NC}"
				exit 1
		fi
		chmod +x "$file"
		echo "Executing ${file}..."
		./"$file"
}

# Cleanup function
cleanup() {
		rm -f /root/cf.sh
		rm -f /root/ssh-vpn.sh
		rm -f /root/sslh-fix.sh
		rm -f /root/getupdate.sh
		rm -f /root/ins-xray.sh
		rm -f /root/ipsec.sh
		rm -f /root/set-br.sh
		rm -f /root/edu.sh
		rm -f /root/ohp.sh
		rm -f /root/addhost.sh
		rm -f /root/newhost.sh
}

# Get Server IP
get_server_ip() {
    server_ip=$(curl -s ipv4.icanhazip.com)
    if [[ -z "$server_ip" ]]; then
        server_ip=$(curl -s ipinfo.io/ip)
    fi
    if [[ -z "$server_ip" ]]; then
        echo "Error: Could not determine server IP address"
        exit 1
    fi
    echo "$server_ip"
}

# Add IP validation before installation
validate_ip() {
    server_ip=$(get_server_ip)
    echo "Server IP: $server_ip"
    echo "Validating server IP..."
    
    # Basic IP validation
    if [[ ! $server_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: Invalid IP address format"
        exit 1
    fi
}

# Main execution
echo "Starting installation..."
check_os_support
check_system_requirements
validate_ip
update_system
main_install
cleanup

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
# ==========================================
# Link Hosting You For Ssh Vpn
sshlink="raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/ssh"
# Link Hosting You For Sstp
# gl33chervpnn="raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/sstp"
# Link Hosting You For Ssr
# gl33chervpnnn="raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/ssr"
# Link Hosting You For Shadowsocks
# gl33chervpnnnn="raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/shadowsocks"
# Link Hosting You For Wireguard
# gl33chervpnnnnn="raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/wireguard"
# Link Hosting You For Xray
xraylink="raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/xray1"
# Link Hosting You For Ipsec
# gl33chervpnnnnnnn="raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/ipsec"
# Link Hosting You For Backup
backuplink="raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/backup"
# Link Hosting You For Websocket
websocketlink="raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/websocket"
# Link Hosting You For Ohp
ohplink="raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/ohp"
# link Hosting update
updatelink="raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/update"
# link Hosting sslh-fix
sslhlink="raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/sslh-fix"

cat <<EOF> /etc/systemd/system/autosett.service
[Unit]
Description=autosetting
Documentation=https://t.me/cdnvpn

[Service]
Type=oneshot
ExecStart=/bin/bash /etc/set.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable autosett
wget -O /etc/set.sh "https://${sshlink}/set.sh"
chmod +x /etc/set.sh
sslh-fix-reboot
history -c
echo "1.2" > /home/ver
echo " "
echo "Installation has been completed!!"
echo " "
echo "=================================-Abdofaiz Project-===========================" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "----------------------------------------------------------------------------" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Service & Port"  | tee -a log-install.txt
echo "   - OpenSSH                 : 443, 22"  | tee -a log-install.txt
echo "   - OpenVPN                 : TCP 1194, UDP 2200, SSL 990"  | tee -a log-install.txt
echo "   - Stunnel5                : 443, 445, 777"  | tee -a log-install.txt
echo "   - Dropbear                : 443, 109, 143"  | tee -a log-install.txt
echo "   - Squid Proxy             : 3128, 8080"  | tee -a log-install.txt
echo "   - Badvpn                  : 7100, 7200, 7300"  | tee -a log-install.txt
echo "   - Nginx                   : 89"  | tee -a log-install.txt
echo "   - XRAYS Vmess TLS         : 8443"  | tee -a log-install.txt
echo "   - XRAYS Vmess None TLS    : 80"  | tee -a log-install.txt
echo "   - XRAYS Vless TLS         : 8443"  | tee -a log-install.txt
echo "   - XRAYS Vless None TLS    : 80"  | tee -a log-install.txt
echo "   - XRAYS Trojan            : 2083"  | tee -a log-install.txt
echo "   - Websocket TLS           : 443"  | tee -a log-install.txt
echo "   - Websocket None TLS      : 80"  | tee -a log-install.txt
echo "   - Websocket Ovpn          : 2086"  | tee -a log-install.txt
echo "   - OHP SSH                 : 8181"  | tee -a log-install.txt
echo "   - OHP Dropbear            : 8282"  | tee -a log-install.txt
echo "   - OHP OpenVPN             : 8383"  | tee -a log-install.txt
echo "   - Tr Go                   : 2087"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Server Information & Other Features"  | tee -a log-install.txt
echo "   - Timezone                : Asia/Manila (GMT +8)"  | tee -a log-install.txt
echo "   - Fail2Ban                : [ON]"  | tee -a log-install.txt
echo "   - Dflate                  : [ON]"  | tee -a log-install.txt
echo "   - IPtables                : [ON]"  | tee -a log-install.txt
echo "   - Auto-Reboot             : [ON]"  | tee -a log-install.txt
echo "   - IPv6                    : [OFF]"  | tee -a log-install.txt
echo "   - Autoreboot On 06.00 GMT +8" | tee -a log-install.txt
echo "   - Autobackup Data" | tee -a log-install.txt
echo "   - Restore Data" | tee -a log-install.txt
echo "   - Auto Delete Expired Account" | tee -a log-install.txt
echo "   - Full Orders For Various Services" | tee -a log-install.txt
echo "   - White Label" | tee -a log-install.txt
echo "   - Installation Log --> /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "---------------------- Script Mod By Faiz ----------------------" | tee -a log-install.txt
echo ""
echo " Reboot 15 Sec"
sleep 15
