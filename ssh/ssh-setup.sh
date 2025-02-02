#!/bin/bash
# SSH Setup Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# SSH Configuration
echo -e "${GREEN}Configuring SSH...${NC}"
cat > /etc/ssh/sshd_config <<EOF
Port 22
Port 443
ListenAddress 0.0.0.0
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
PermitRootLogin yes
MaxSessions 1024
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
ClientAliveInterval 240
ClientAliveCountMax 2
UseDNS no
Banner /etc/issue.net
AcceptEnv LANG LC_*
Subsystem   sftp  /usr/lib/openssh/sftp-server
EOF

# Setup SSH Banner
cat > /etc/issue.net <<EOF
<font color="blue"><b>Premium VPS</b></font><br>
<font color="red"><b>No DDOS</b></font><br>
<font color="black"><b>No Spam</b></font><br>
<font color="red"><b>No Carding</b></font><br>
<font color="black"><b>No Torrent</b></font><br>
<font color="red"><b>No Multi-Login</b></font><br>
EOF

# Squid Configuration
echo -e "${GREEN}Configuring Squid Proxy...${NC}"
cat > /etc/squid/squid.conf <<EOF
acl localhost src 127.0.0.1/32 ::1
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 ::1
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
http_access allow manager localhost
http_access deny manager
http_access allow localhost
http_access deny all
http_port 8080
http_port 3128
coredump_dir /var/spool/squid
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
visible_hostname Premium-VPS
EOF

# Restart Services
systemctl restart ssh
systemctl restart squid

echo -e "${GREEN}SSH and Squid setup completed!${NC}" 