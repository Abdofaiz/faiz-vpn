#!/bin/bash

install_packages() {
    # Update system
    apt update
    apt upgrade -y
    
    # Install dependencies
    apt install -y \
        curl \
        wget \
        socat \
        ufw \
        nginx \
        certbot \
        python3-certbot-nginx \
        uuid-runtime \
        stunnel4 \
        dropbear \
        squid \
        jq \
        bc

    # Install XRAY
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
} 