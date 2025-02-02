#!/bin/bash
# L2TP/IPSec Setup Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Install required packages
apt install -y strongswan xl2tpd net-tools

# Generate PSK
PSK=$(openssl rand -hex 30)

# Configure IPSec
cat > /etc/ipsec.conf <<EOF
config setup
    charondebug="ike 1, knl 1, cfg 0"
    uniqueids=no

conn L2TP-PSK-NAT
    type=transport
    keyexchange=ikev1
    authby=secret
    keyingtries=3
    rekey=no
    left=%any
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/1701
    dpddelay=30
    dpdtimeout=120
    dpdaction=clear
    auto=add
EOF

# Set PSK
cat > /etc/ipsec.secrets <<EOF
: PSK "${PSK}"
EOF

# Configure xl2tpd
cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[global]
ipsec saref = yes
saref refinfo = 30
port = 1701
access control = no
debug avp = no
debug network = no
debug state = no
debug tunnel = no

[lns default]
ip range = 172.16.1.30-172.16.1.100
local ip = 172.16.1.1
require chap = yes
refuse pap = yes
require authentication = yes
name = l2tpd
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

# Configure PPP
cat > /etc/ppp/options.xl2tpd <<EOF
ipcp-accept-local
ipcp-accept-remote
ms-dns 8.8.8.8
ms-dns 8.8.4.4
noccp
auth
crtscts
idle 1800
mtu 1460
mru 1460
nodefaultroute
debug
lock
proxyarp
connect-delay 5000
EOF

# Create PPP credentials directory
mkdir -p /etc/ppp/chap-secrets.d

# Configure firewall for L2TP/IPSec
iptables -A INPUT -p udp --dport 500 -j ACCEPT
iptables -A INPUT -p udp --dport 4500 -j ACCEPT
iptables -A INPUT -p udp --dport 1701 -j ACCEPT
iptables -A INPUT -p tcp --dport 1701 -j ACCEPT
iptables -A FORWARD -i ppp+ -j ACCEPT
iptables -A FORWARD -o ppp+ -j ACCEPT
iptables -t nat -A POSTROUTING -s 172.16.1.0/24 -o eth0 -j MASQUERADE

# Save iptables rules
iptables-save > /etc/iptables/rules.v4

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.conf
sysctl -p

# Create user management script
cat > /usr/local/bin/l2tp-manage <<EOF
#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

case \$1 in
    add)
        if [ \$# -ne 3 ]; then
            echo "Usage: \$0 add username password"
            exit 1
        fi
        echo "\$2 l2tpd \$3 *" >> /etc/ppp/chap-secrets
        echo -e "\${GREEN}User \$2 added\${NC}"
        ;;
    del)
        if [ \$# -ne 2 ]; then
            echo "Usage: \$0 del username"
            exit 1
        fi
        sed -i "/^\$2 l2tpd/d" /etc/ppp/chap-secrets
        echo -e "\${GREEN}User \$2 deleted\${NC}"
        ;;
    list)
        echo -e "\${GREEN}L2TP Users:\${NC}"
        grep "l2tpd" /etc/ppp/chap-secrets | cut -d' ' -f1
        ;;
    *)
        echo "Usage: \$0 {add|del|list}"
        exit 1
        ;;
esac
EOF

chmod +x /usr/local/bin/l2tp-manage

# Create client config generator
cat > /usr/local/bin/l2tp-config <<EOF
#!/bin/bash
if [ \$# -ne 2 ]; then
    echo "Usage: \$0 username password"
    exit 1
fi

SERVER_IP=\$(curl -s ifconfig.me)
PSK=\$(grep "PSK" /etc/ipsec.secrets | cut -d'"' -f2)

cat << END
L2TP/IPSec Configuration:
========================
Server IP: \$SERVER_IP
PSK: \$PSK
Username: \$1
Password: \$2

For iOS/macOS:
1. Go to Network Settings
2. Add VPN Configuration
3. Type: L2TP
4. Server: \$SERVER_IP
5. Account: \$1
6. Password: \$2
7. Secret: \$PSK

For Android:
1. Go to Settings > Network & Internet > VPN
2. Add VPN Profile
3. Type: L2TP/IPSec PSK
4. Server: \$SERVER_IP
5. PSK: \$PSK
6. Username: \$1
7. Password: \$2
END
EOF

chmod +x /usr/local/bin/l2tp-config

# Enable and start services
systemctl enable strongswan
systemctl enable xl2tpd
systemctl restart strongswan
systemctl restart xl2tpd

echo -e "${GREEN}L2TP/IPSec setup completed!${NC}"
echo -e "PSK: ${PSK}"
echo -e "Use 'l2tp-manage' to manage users"
echo -e "Use 'l2tp-config' to generate client configs" 