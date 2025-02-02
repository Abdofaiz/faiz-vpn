#!/bin/bash
# API Server Setup Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# API Configuration
API_PORT=8069
API_CONFIG="/root/api_config.json"

# Setup API Server
setup_api() {
    clear
    echo -e "${BLUE}=== API Server Setup ===${NC}"
    
    # Install requirements
    pip3 install flask flask-restful gunicorn

    # Create API server script
    cat > /usr/local/bin/vps-api.py <<EOF
#!/usr/bin/python3
from flask import Flask, request, jsonify
from functools import wraps
import json
import subprocess
import os
from datetime import datetime

app = Flask(__name__)

# Load config
def load_config():
    with open('$API_CONFIG', 'r') as f:
        return json.load(f)

# Auth decorator
def require_api_key(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        api_key = request.headers.get('X-API-Key')
        if not api_key or api_key not in load_config()['api_keys']:
            return jsonify({"error": "Invalid API key"}), 401
        return f(*args, **kwargs)
    return decorated

# User Management Endpoints
@app.route('/user/add', methods=['POST'])
@require_api_key
def add_user():
    data = request.json
    type = data.get('type')
    username = data.get('username')
    password = data.get('password')
    duration = data.get('duration')
    
    if type == 'ssh':
        cmd = f"useradd -e \$(date -d '+{duration} days' +%Y-%m-%d) -s /bin/false {username}"
        os.system(cmd)
        os.system(f"echo '{username}:{password}' | chpasswd")
    elif type == 'xray':
        # Add XRAY user using jq
        uuid = os.popen('cat /proc/sys/kernel/random/uuid').read().strip()
        os.system(f"""jq --arg user "{username}" --arg uuid "{uuid}" '.inbounds[0].settings.clients += [{{"id": $uuid, "email": $user}}]' /usr/local/etc/xray/config.json > /tmp/tmp.json && mv /tmp/tmp.json /usr/local/etc/xray/config.json""")
        os.system("systemctl restart xray")
    
    return jsonify({"message": f"User {username} created successfully"})

@app.route('/user/delete/<username>', methods=['DELETE'])
@require_api_key
def delete_user(username):
    os.system(f"userdel -r {username} 2>/dev/null")
    os.system(f"""jq --arg user "{username}" 'walk(if type == "object" and .clients then .clients |= map(select(.email != $user)) else . end)' /usr/local/etc/xray/config.json > /tmp/tmp.json && mv /tmp/tmp.json /usr/local/etc/xray/config.json""")
    os.system("systemctl restart xray")
    return jsonify({"message": f"User {username} deleted"})

@app.route('/user/status/<username>', methods=['GET'])
@require_api_key
def user_status(username):
    # Get SSH status
    ssh_logins = int(os.popen(f"who | grep '^{username} ' | wc -l").read().strip())
    
    # Get XRAY status
    xray_logins = int(os.popen(f"netstat -anp | grep ESTABLISHED | grep xray | grep -i {username} | wc -l").read().strip())
    
    # Get quota info
    quota_data = os.popen(f"grep '^{username} ' /root/user_quota.txt").read().strip().split()
    quota_limit = int(quota_data[1]) if len(quota_data) > 1 else 0
    quota_used = int(quota_data[2]) if len(quota_data) > 2 else 0
    
    # Get expiry
    expiry = os.popen(f"chage -l {username} | grep 'Account expires' | cut -d: -f2").read().strip()
    
    return jsonify({
        "status": "active",
        "ssh_logins": ssh_logins,
        "xray_logins": xray_logins,
        "quota_limit": quota_limit,
        "quota_used": quota_used,
        "expiry": expiry
    })

@app.route('/user/lock/<username>', methods=['POST'])
@require_api_key
def lock_user(username):
    os.system(f"passwd -l {username}")
    return jsonify({"message": f"User {username} locked"})

@app.route('/user/unlock/<username>', methods=['POST'])
@require_api_key
def unlock_user(username):
    os.system(f"passwd -u {username}")
    return jsonify({"message": f"User {username} unlocked"})

@app.route('/server/status', methods=['GET'])
@require_api_key
def server_status():
    cpu = os.popen("top -bn1 | grep 'Cpu(s)' | awk '{print $2}'").read().strip()
    mem = os.popen("free -m | grep Mem | awk '{print $3/$2 * 100.0}'").read().strip()
    disk = os.popen("df -h / | tail -1 | awk '{print $5}'").read().strip()
    
    return jsonify({
        "cpu_usage": float(cpu),
        "memory_usage": float(mem),
        "disk_usage": disk,
        "uptime": os.popen("uptime -p").read().strip()
    })

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=$API_PORT)
EOF

    # Create service file
    cat > /etc/systemd/system/vps-api.service <<EOF
[Unit]
Description=VPS API Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/gunicorn --bind 127.0.0.1:$API_PORT vps-api:app
WorkingDirectory=/usr/local/bin
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    # Create initial API config
    cat > $API_CONFIG <<EOF
{
    "api_keys": ["$(openssl rand -hex 32)"],
    "allowed_ips": ["127.0.0.1"]
}
EOF

    # Start API service
    systemctl enable vps-api
    systemctl start vps-api
    
    echo -e "${GREEN}API server setup completed!${NC}"
    echo -e "API running on port $API_PORT"
    echo -e "Initial API key: $(jq -r '.api_keys[0]' $API_CONFIG)"
}

# Manage API keys
manage_keys() {
    clear
    echo -e "${BLUE}=== Manage API Keys ===${NC}"
    echo -e "1) Add API Key"
    echo -e "2) Remove API Key"
    echo -e "3) List API Keys"
    echo -e "0) Back"
    
    read -p "Select option: " choice
    case $choice in
        1)
            new_key=$(openssl rand -hex 32)
            jq --arg key "$new_key" '.api_keys += [$key]' $API_CONFIG > /tmp/tmp.json
            mv /tmp/tmp.json $API_CONFIG
            echo -e "${GREEN}New API key added: $new_key${NC}"
            ;;
        2)
            echo "Current API keys:"
            jq -r '.api_keys[]' $API_CONFIG | nl
            read -p "Enter number to remove: " num
            jq "del(.api_keys[$((num-1))])" $API_CONFIG > /tmp/tmp.json
            mv /tmp/tmp.json $API_CONFIG
            echo -e "${GREEN}API key removed${NC}"
            ;;
        3)
            echo -e "${YELLOW}API Keys:${NC}"
            jq -r '.api_keys[]' $API_CONFIG | nl
            ;;
    esac
}

# Main Menu
while true; do
    clear
    echo -e "${BLUE}=== API Server Manager ===${NC}"
    echo -e "1) Setup API Server"
    echo -e "2) Manage API Keys"
    echo -e "3) Show API Status"
    echo -e "4) Restart API Server"
    echo -e "5) View API Logs"
    echo -e "0) Back to Main Menu"
    
    read -p "Select option: " option
    case $option in
        1) setup_api ;;
        2) manage_keys ;;
        3) systemctl status vps-api ;;
        4) systemctl restart vps-api ;;
        5) journalctl -u vps-api ;;
        0) break ;;
    esac
    read -p "Press enter to continue..."
done 