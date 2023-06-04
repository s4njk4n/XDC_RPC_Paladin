#!/bin/bash

# Check if sudo is required
if [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
fi

# Load settings from settings.txt
source settings.txt

# Function to send email
send_email() {
    local subject="$1"
    local body="$2"
    local to_address="$3"
    local from_address="RPC_Alert_${RPC_IP}"

    $SUDO bash -c "echo -e \"Subject:${subject}\nFrom:${from_address}\n${body}\" | /usr/sbin/sendmail -t ${to_address}"
}

# Function to log results
log_result() {
    local result="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    echo "[${timestamp}] ${result}" >> rpc_check.log
}

# Check if an alert email was already sent within the last hour
last_email_time=$(grep "RPC_Alert_" rpc_check.log | tail -1 | awk '{print $2" "$3}')
last_email_timestamp=$(date -d "${last_email_time}" +"%s")
current_timestamp=$(date +"%s")
time_diff=$((current_timestamp - last_email_timestamp))
if [[ $time_diff -lt 3600 ]]; then
    log_result "Alert email already sent within the last hour. Skipping..."
    exit 0
fi

# Send HTTP HEAD request to RPC port
response_code=$(curl -o /dev/null -s -w "%{http_code}" --connect-timeout 10 "${RPC_URL}")
if [[ $response_code -eq 200 ]]; then
    log_result "RPC is working fine."
else
    log_result "RPC is not responding. Sending alert email..."
    email_subject="RPC Alert - ${RPC_IP}"
    email_body="The RPC at ${RPC_URL} is not responding."

    send_email "${email_subject}" "${email_body}" "${ALERT_EMAIL}"
fi
