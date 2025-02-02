#!/bin/bash
# Backup and Restore Setup Script

# Create backup directory
mkdir -p /root/backup

# Create backup script
cat > /usr/local/bin/backup-vps <<EOF
#!/bin/bash
# VPS Backup Script

BACKUP_DIR="/root/backup"
DATE=\$(date +%Y-%m-%d)
BACKUP_FILE="\$BACKUP_DIR/backup-\$DATE.tar.gz"

# Create backup directory if not exists
mkdir -p \$BACKUP_DIR

# Backup important directories and configurations
tar czf \$BACKUP_FILE \
    /etc/xray \
    /etc/trojan-go \
    /etc/openvpn \
    /etc/ssh \
    /etc/stunnel5 \
    /etc/systemd/system/ohp-*.service \
    /usr/local/etc/xray \
    /usr/local/etc/trojan-go

echo "Backup completed: \$BACKUP_FILE"
EOF

# Create restore script
cat > /usr/local/bin/restore-vps <<EOF
#!/bin/bash
# VPS Restore Script

if [ -z "\$1" ]; then
    echo "Usage: restore-vps <backup-file>"
    exit 1
fi

if [ ! -f "\$1" ]; then
    echo "Backup file not found!"
    exit 1
fi

# Stop services
systemctl stop xray
systemctl stop trojan-go
systemctl stop openvpn
systemctl stop stunnel5
systemctl stop ohp-ssh
systemctl stop ohp-dropbear
systemctl stop ohp-openvpn

# Restore backup
tar xzf "\$1" -C /

# Start services
systemctl start xray
systemctl start trojan-go
systemctl start openvpn
systemctl start stunnel5
systemctl start ohp-ssh
systemctl start ohp-dropbear
systemctl start ohp-openvpn

echo "Restore completed!"
EOF

# Make scripts executable
chmod +x /usr/local/bin/backup-vps
chmod +x /usr/local/bin/restore-vps

# Setup automatic daily backup
echo "0 0 * * * root /usr/local/bin/backup-vps" >> /etc/crontab 