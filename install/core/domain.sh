#!/bin/bash

setup_domain() {
    # Get domain
    read -p "Enter your domain: " domain
    echo "$domain" > /etc/xray/domain

    # Setup SSL
    certbot --nginx -d $domain --non-interactive --agree-tos --email admin@$domain
    
    # Copy certificates
    cp /etc/letsencrypt/live/$domain/fullchain.pem /etc/xray/xray.crt
    cp /etc/letsencrypt/live/$domain/privkey.pem /etc/xray/xray.key
} 