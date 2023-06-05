#!/bin/bash

# Ask user for email address
read -p "Enter the email address to receive alert emails: " ALERT_EMAIL

# Ask user for RPC URL
read -p "Enter the RPC URL to check: " RPC_URL

# Store user-defined data in settings.txt file
echo "ALERT_EMAIL=$ALERT_EMAIL" > "$(dirname "$0")/settings.txt"
echo "RPC_URL=$RPC_URL" >> "$(dirname "$0")/settings.txt"
