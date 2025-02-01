#!/bin/bash

# Install OpenSSH with port 443 and 80
print_info "Installing OpenSSH..."
apt install -y openssh-server

# Configure SSH ports
cat > /etc/ssh/sshd_config << EOF
Port 443
Port 80
AddressFamily inet
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
EOF

systemctl restart ssh
print_success "OpenSSH installed and configured for ports 443 and 80" 