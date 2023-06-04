#!/bin/bash

# Read settings from settings.txt
source settings.txt

# Generate the from address for the email
from_address="RPC_Alert_$rpc_server_ip"

# Check if an alert email has been sent within the last hour
last_alert=$(grep -i "$from_address" rpc_check.log | tail -n 1 | awk '{print $1 " " $2}')
last_alert_timestamp=$(date -d "$last_alert" +%s)
current_timestamp=$(date +%s)
time_diff=$((current_timestamp - last_alert_timestamp))
if [ $time_diff -gt 3600 ]; then
  # Send HTTP HEAD request and check the response
  response=$(curl -sI "$rpc_server_ip:$rpc_port")
  if [[ ! $response =~ "200 OK" ]]; then
    # Send email alert
    echo "Sending alert email..."
    echo -e "Subject: RPC Alert\n\nThere was an issue with the RPC server at $rpc_server_ip:$rpc_port" | ssmtp "$email_address"
    echo "$(date) - Alert email sent" >> rpc_check.log
  else
    echo "$(date) - RPC server is functioning properly" >> rpc_check.log
  fi
else
  echo "$(date) - Alert email already sent within the last hour" >> rpc_check.log
fi
