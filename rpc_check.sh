#!/bin/bash

# Check if running as root, otherwise run with sudo
if [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
fi

# Load settings from settings.txt
source settings.txt

# Function to send an email
send_email() {
    local subject="$1"
    local body="$2"
    local from_address="RPC_Alert_$RPC_IP"

    $SUDO apt-get install -y mailutils
    echo -e "$body" | $SUDO mail -s "$subject" "$EMAIL_ADDRESS"
}

# Check if an alert email has been sent within the past hour
alert_sent=false
if [[ -f rpc_check.log ]]; then
    last_alert_time=$(tail -n 1 rpc_check.log | awk '{print $1 " " $2}')
    last_alert_timestamp=$(date -d "$last_alert_time" +%s)
    current_timestamp=$(date +%s)
    time_diff=$((current_timestamp - last_alert_timestamp))
    if [[ $time_diff -lt 3600 ]]; then
        alert_sent=true
    fi
fi

# Send HTTP HEAD request and check response
response=$(curl -sSf -m 10 --head "$RPC_URL")
status=$?

if [[ $status -eq 0 ]]; then
    if [[ $response == *"200 OK"* ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - RPC check successful" >>rpc_check.log
    else
        if [[ $alert_sent == false ]]; then
            send_email "RPC Check Alert" "RPC check failed. No appropriate response received."
            echo "$(date '+%Y-%m-%d %H:%M:%S') - RPC check failed. Alert email sent" >>rpc_check.log
        fi
    fi
else
    if [[ $alert_sent == false ]]; then
        send_email "RPC Check Alert" "RPC check failed. No response received."
        echo "$(date '+%Y-%m-%d %H:%M:%S') - RPC check failed. Alert email sent" >>rpc_check.log
    fi
fi
