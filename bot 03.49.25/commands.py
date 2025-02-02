# Add these command handlers to your bot

@bot.message_handler(commands=['lockxray'])
def lock_xray_cmd(message):
    if not is_authorized(message.from_user.id):
        bot.reply_to(message, "Unauthorized access")
        return

    try:
        username = message.text.split()[1]
        response = requests.post(f"{API_URL}/account/lock/xray/{username}", 
                               headers={'X-API-Key': API_KEY})
        result = response.json()
        bot.reply_to(message, result['message'])
    except Exception as e:
        bot.reply_to(message, f"Error: {str(e)}")

@bot.message_handler(commands=['unlockxray'])
def unlock_xray_cmd(message):
    if not is_authorized(message.from_user.id):
        bot.reply_to(message, "Unauthorized access")
        return

    try:
        username = message.text.split()[1]
        response = requests.post(f"{API_URL}/account/unlock/xray/{username}", 
                               headers={'X-API-Key': API_KEY})
        result = response.json()
        bot.reply_to(message, result['message'])
    except Exception as e:
        bot.reply_to(message, f"Error: {str(e)}")

@bot.message_handler(commands=['lockssh'])
def lock_ssh_cmd(message):
    if not is_authorized(message.from_user.id):
        bot.reply_to(message, "Unauthorized access")
        return

    try:
        username = message.text.split()[1]
        response = requests.post(f"{API_URL}/account/lock/ssh/{username}", 
                               headers={'X-API-Key': API_KEY})
        result = response.json()
        bot.reply_to(message, result['message'])
    except Exception as e:
        bot.reply_to(message, f"Error: {str(e)}")

@bot.message_handler(commands=['unlockssh'])
def unlock_ssh_cmd(message):
    if not is_authorized(message.from_user.id):
        bot.reply_to(message, "Unauthorized access")
        return

    try:
        username = message.text.split()[1]
        response = requests.post(f"{API_URL}/account/unlock/ssh/{username}", 
                               headers={'X-API-Key': API_KEY})
        result = response.json()
        bot.reply_to(message, result['message'])
    except Exception as e:
        bot.reply_to(message, f"Error: {str(e)}")

@bot.message_handler(commands=['xrayinfo'])
def xray_info_cmd(message):
    if not is_authorized(message.from_user.id):
        bot.reply_to(message, "Unauthorized access")
        return

    try:
        username = message.text.split()[1]
        response = requests.get(f"{API_URL}/account/details/xray/{username}", 
                              headers={'X-API-Key': API_KEY})
        details = response.json()
        
        if 'error' in details:
            bot.reply_to(message, f"Error: {details['error']}")
            return

        info = f"""
XRAY Account Details:
Username: {details['username']}
UUID: {details['uuid']}
Protocol: {details['protocol']}
Port: {details['port']}
Status: {details['status']}
"""
        bot.reply_to(message, info)
    except Exception as e:
        bot.reply_to(message, f"Error: {str(e)}") 