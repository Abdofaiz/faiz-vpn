#!/bin/bash
# Auto Delete Expired Users Script

# Add to crontab
echo "0 1 * * * root /usr/local/bin/check-expired" >> /etc/crontab

# Create check expired script
cat > /usr/local/bin/check-expired <<EOF
#!/bin/bash
source /usr/local/bin/user-management.sh
check_expired
EOF

chmod +x /usr/local/bin/check-expired 