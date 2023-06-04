#!/bin/bash

# Check if sudo is required
if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
fi

# Load settings from settings.txt
source settings.txt

# Function to send email
send_email() {
    local subject=$1
    local body=$2

    echo -e "$body" | $SUDO mail -s "$subject" "$ALERT_EMAIL"
}

# Check if an alert email was sent in the last hour
is_alert_sent() {
    local log_file="rpc_check.log"

    if [ -f "$log_file" ]; then
        local last_hour=$(date -d '1 hour ago' '+%Y-%m-%d %H:%M:%S')

        if grep -q "$last_hour" "$log_file"; then
            return 0
        fi
    fi

    return 1
}

# Perform HTTP HEAD request and check response
response=$(timeout 10s curl -s -I "$RPC_URL")

if [ $? -eq 0 ]; then
    if [[ $response == *"200 OK"* ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - RPC check successful" >>rpc_check.log
    else
        if ! is_alert_sent; then
            subject="RPC Alert - $RPC_URL"
            body="No appropriate response from $RPC_URL"
            send_email "$subject" "$body"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Alert email sent" >>rpc_check.log
        fi
    fi
else
    if ! is_alert_sent; then
        subject="RPC Alert - $RPC_URL"
        body="Error connecting to $RPC_URL"
        send_email "$subject" "$body"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Alert email sent" >>rpc_check.log
    fi
fi
