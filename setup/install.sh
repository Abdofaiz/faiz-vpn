#!/bin/bash
# VPS Installation Script

# Download all components
wget -O /root/autoscript.zip https://github.com/yourusername/autoscript/archive/main.zip
unzip /root/autoscript.zip -d /root/
mv /root/autoscript-main /root/autoscript

# Make all scripts executable
find /root/autoscript -type f -name "*.sh" -exec chmod +x {} \;

# Create symbolic links
ln -sf /root/autoscript/menu/advanced-menu.sh /usr/local/bin/menu
ln -sf /root/autoscript/menu/ssh-manager.sh /usr/local/bin/ssh-manager.sh
ln -sf /root/autoscript/menu/xray-manager.sh /usr/local/bin/xray-manager.sh
ln -sf /root/autoscript/menu/openvpn-manager.sh /usr/local/bin/openvpn-manager.sh
ln -sf /root/autoscript/menu/l2tp-manager.sh /usr/local/bin/l2tp-manager.sh
ln -sf /root/autoscript/menu/service-manager.sh /usr/local/bin/service-manager.sh
ln -sf /root/autoscript/menu/system-tools.sh /usr/local/bin/system-tools.sh
ln -sf /root/autoscript/menu/security-center.sh /usr/local/bin/security-center.sh
ln -sf /root/autoscript/menu/backup-manager.sh /usr/local/bin/backup-manager.sh

# Run main setup
bash /root/autoscript/setup/main-setup.sh

# Create auto-start script
cat > /etc/systemd/system/vps-startup.service <<EOF
[Unit]
Description=VPS Startup Script
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/vps-startup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Create startup script
cat > /usr/local/bin/vps-startup.sh <<EOF
#!/bin/bash
# Restore iptables rules
iptables-restore < /etc/iptables/rules.v4

# Start all services
systemctl restart ssh
systemctl restart dropbear
systemctl restart stunnel4
systemctl restart openvpn*
systemctl restart xray
systemctl restart xl2tpd
systemctl restart slowdns-server
systemctl restart badvpn-udpgw

# Clear expired users
/usr/local/bin/delete-expired
EOF

chmod +x /usr/local/bin/vps-startup.sh
systemctl enable vps-startup

echo "Installation completed! Use 'menu' command to start." 