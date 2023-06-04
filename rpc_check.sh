#!/bin/bash

LOG_FILE="rpc_check.log"
MAIL_SETTINGS_FILE="mail_settings.txt"

# Load mail settings
if [ -f "$MAIL_SETTINGS_FILE" ]; then
    source "$MAIL_SETTINGS_FILE"
else
    echo "Error: $MAIL_SETTINGS_FILE not found."
    exit 1
fi

# Function to send email alert
send_alert_email() {
    subject="RPC Alert - Issue detected with RPC on $RPC_IP_ADDRESS"
    body="There was an issue with the RPC on $RPC_IP_ADDRESS. Please check the logs for more information."

    echo -e "Subject:$subject\n$body" | ssmtp -v -s "$SMTP_HOST:$SMTP_PORT" "$EMAIL_ADDRESS_TO"
}

# Function to perform RPC check
perform_rpc_check() {
    # Perform HTTP HEAD request to RPC and capture the response
    response=$(curl -s -I --connect-timeout 5 "http://$RPC_IP_ADDRESS:8989")

    # Check if the response is correct
    if [[ $response == *"200 OK"* ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] RPC is working fine."
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] RPC is not responding properly. Sending alert email..."
        send_alert_email
    fi
}

# Main script
echo "Running rpc_check.sh..."

# Perform RPC check
perform_rpc_check >> "$LOG_FILE"

echo "RPC check completed."
