#!/usr/bin/python3
# VPS API Python Client

import requests
import json
import sys
from datetime import datetime

class VPSClient:
    def __init__(self, base_url, api_key):
        self.base_url = base_url
        self.headers = {
            'X-API-Key': api_key,
            'Content-Type': 'application/json'
        }
    
    def create_user(self, type, username, password, duration):
        url = f"{self.base_url}/user/add"
        data = {
            "type": type,
            "username": username,
            "password": password,
            "duration": duration
        }
        return requests.post(url, headers=self.headers, json=data).json()
    
    def delete_user(self, username):
        url = f"{self.base_url}/user/delete/{username}"
        return requests.delete(url, headers=self.headers).json()
    
    def check_user(self, username):
        url = f"{self.base_url}/user/status/{username}"
        return requests.get(url, headers=self.headers).json()
    
    def lock_user(self, username):
        url = f"{self.base_url}/user/lock/{username}"
        return requests.post(url, headers=self.headers).json()
    
    def unlock_user(self, username):
        url = f"{self.base_url}/user/unlock/{username}"
        return requests.post(url, headers=self.headers).json()
    
    def server_status(self):
        url = f"{self.base_url}/server/status"
        return requests.get(url, headers=self.headers).json()
    
    def create_backup(self):
        url = f"{self.base_url}/backup/create"
        response = requests.post(url, headers=self.headers)
        if response.status_code == 200:
            filename = f"backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.tar.gz"
            with open(filename, 'wb') as f:
                f.write(response.content)
            return f"Backup saved as {filename}"
        return "Backup failed"

# Example usage
if __name__ == "__main__":
    client = VPSClient('http://your-server:8069', 'your-api-key')
    
    if len(sys.argv) < 2:
        print("Usage: python3 vps-client.py [command] [args...]")
        sys.exit(1)
    
    command = sys.argv[1]
    
    try:
        if command == "create":
            result = client.create_user(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
        elif command == "delete":
            result = client.delete_user(sys.argv[2])
        elif command == "status":
            result = client.check_user(sys.argv[2])
        elif command == "lock":
            result = client.lock_user(sys.argv[2])
        elif command == "unlock":
            result = client.unlock_user(sys.argv[2])
        elif command == "server":
            result = client.server_status()
        elif command == "backup":
            result = client.create_backup()
        else:
            print("Unknown command")
            sys.exit(1)
        
        print(json.dumps(result, indent=2))
    except Exception as e:
        print(f"Error: {str(e)}") 