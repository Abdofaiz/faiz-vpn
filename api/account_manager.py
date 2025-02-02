#!/usr/bin/python3
from flask import jsonify, request
import subprocess
import json
import os

class AccountManager:
    def __init__(self):
        self.xray_config = "/usr/local/etc/xray/config.json"
        self.lock_file = "/root/locked_accounts.json"
        self.load_locked_accounts()

    def load_locked_accounts(self):
        if os.path.exists(self.lock_file):
            with open(self.lock_file, 'r') as f:
                self.locked = json.load(f)
        else:
            self.locked = {"ssh": [], "xray": []}
            self.save_locked_accounts()

    def save_locked_accounts(self):
        with open(self.lock_file, 'w') as f:
            json.dump(self.locked, f)

    def lock_xray(self, username):
        try:
            # Read current config
            with open(self.xray_config, 'r') as f:
                config = json.load(f)

            # Find and remove user
            for inbound in config['inbounds']:
                if 'clients' in inbound.get('settings', {}):
                    clients = inbound['settings']['clients']
                    for client in clients:
                        if client.get('email') == username:
                            # Store client config for unlocking
                            if username not in self.locked['xray']:
                                self.locked['xray'].append({
                                    'username': username,
                                    'config': client
                                })
                            clients.remove(client)

            # Save modified config
            with open(self.xray_config, 'w') as f:
                json.dump(config, f, indent=2)

            self.save_locked_accounts()
            subprocess.run(['systemctl', 'restart', 'xray'])
            return True, "Account locked successfully"
        except Exception as e:
            return False, str(e)

    def unlock_xray(self, username):
        try:
            # Find locked account
            locked_account = None
            for acc in self.locked['xray']:
                if acc['username'] == username:
                    locked_account = acc
                    break

            if not locked_account:
                return False, "Account not found in locked list"

            # Read current config
            with open(self.xray_config, 'r') as f:
                config = json.load(f)

            # Add user back
            for inbound in config['inbounds']:
                if 'clients' in inbound.get('settings', {}):
                    inbound['settings']['clients'].append(locked_account['config'])

            # Save modified config
            with open(self.xray_config, 'w') as f:
                json.dump(config, f, indent=2)

            # Remove from locked list
            self.locked['xray'].remove(locked_account)
            self.save_locked_accounts()

            subprocess.run(['systemctl', 'restart', 'xray'])
            return True, "Account unlocked successfully"
        except Exception as e:
            return False, str(e)

    def lock_ssh(self, username):
        try:
            subprocess.run(['passwd', '-l', username], check=True)
            if username not in self.locked['ssh']:
                self.locked['ssh'].append(username)
            self.save_locked_accounts()
            return True, "SSH account locked successfully"
        except Exception as e:
            return False, str(e)

    def unlock_ssh(self, username):
        try:
            subprocess.run(['passwd', '-u', username], check=True)
            if username in self.locked['ssh']:
                self.locked['ssh'].remove(username)
            self.save_locked_accounts()
            return True, "SSH account unlocked successfully"
        except Exception as e:
            return False, str(e)

    def get_xray_details(self, username):
        try:
            with open(self.xray_config, 'r') as f:
                config = json.load(f)

            for inbound in config['inbounds']:
                if 'clients' in inbound.get('settings', {}):
                    for client in inbound['settings']['clients']:
                        if client.get('email') == username:
                            return {
                                'username': username,
                                'uuid': client.get('id'),
                                'alterId': client.get('alterId', 0),
                                'protocol': inbound.get('protocol'),
                                'port': inbound.get('port'),
                                'status': 'locked' if username in [a['username'] for a in self.locked['xray']] else 'active'
                            }

            # Check locked accounts
            for acc in self.locked['xray']:
                if acc['username'] == username:
                    return {
                        'username': username,
                        'uuid': acc['config'].get('id'),
                        'alterId': acc['config'].get('alterId', 0),
                        'status': 'locked'
                    }

            return None
        except Exception as e:
            return {'error': str(e)}

account_manager = AccountManager()

# Add these routes to your Flask app:
"""
@app.route('/account/lock/xray/<username>', methods=['POST'])
def lock_xray_account(username):
    success, message = account_manager.lock_xray(username)
    return jsonify({'success': success, 'message': message})

@app.route('/account/unlock/xray/<username>', methods=['POST'])
def unlock_xray_account(username):
    success, message = account_manager.unlock_xray(username)
    return jsonify({'success': success, 'message': message})

@app.route('/account/lock/ssh/<username>', methods=['POST'])
def lock_ssh_account(username):
    success, message = account_manager.lock_ssh(username)
    return jsonify({'success': success, 'message': message})

@app.route('/account/unlock/ssh/<username>', methods=['POST'])
def unlock_ssh_account(username):
    success, message = account_manager.unlock_ssh(username)
    return jsonify({'success': success, 'message': message})

@app.route('/account/details/xray/<username>', methods=['GET'])
def get_xray_account_details(username):
    details = account_manager.get_xray_details(username)
    if details:
        return jsonify(details)
    return jsonify({'error': 'Account not found'}), 404
""" 