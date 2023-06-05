#!/bin/bash

# Check if running as root, otherwise run commands with sudo
if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
fi

# Load settings from settings.txt file
source "$(dirname "$0")/settings.txt"

# Function to send email
send_email() {
    local subject=$1
    local body=$2
    local from_address="RPC_Alert_${RPC_URL}"

    # Check if an alert email has been sent within the last hour
    local last_alert=$(grep -m1 "ALERT:" rpc_check.log | awk '{print $1, $2}')
    local last_alert_timestamp=$(date -d "$last_alert" +"%s")
    local current_timestamp=$(date +"%s")
    local elapsed_time=$((current_timestamp - last_alert_timestamp))

    if [ $elapsed_time -gt 3600 ]; then
        # Send email using local mail server
        echo "$body" | $SUDO mail -s "$subject" -r "$from_address" "$ALERT_EMAIL"
        echo "$(date '+%Y-%m-%d %H:%M:%S') ALERT: Email sent to $ALERT_EMAIL" >> rpc_check.log
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') INFO: Alert email already sent within the last hour" >> rpc_check.log
    fi
}

# Send HTTP HEAD request and check response
response=$(timeout 10 curl --silent --head "$RPC_URL" | grep "200 OK")
if [ -z "$response" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') ALERT: RPC check failed for $RPC_URL" >> rpc_check.log
    send_email "RPC Check Alert" "The RPC at $RPC_URL is not responding correctly."
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') INFO: RPC check successful for $RPC_URL" >> rpc_check.log
fi
