#!/bin/bash

# Check if running as root, otherwise run with sudo
if [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
fi

# Function to ask user for input and store in settings.txt
ask_and_store() {
    local prompt="$1"
    local variable_name="$2"
    
    read -p "$prompt: " user_input
    echo "$variable_name=$user_input" >>settings.txt
}

# Install dependencies
$SUDO apt-get update
$SUDO apt-get install -y curl

# Install and configure mail service
$SUDO apt-get install -y mailutils
$SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y postfix

# Install ufw
$SUDO apt-get install -y ufw

# Perform necessary configurations for mail service
$SUDO sed -i 's/inet_interfaces = all/inet_interfaces = loopback-only/' /etc/postfix/main.cf
$SUDO systemctl restart postfix

# Configure ufw to allow mail server access from localhost
$SUDO ufw allow from 127.0.0.1 to any port 25

# Configure ufw to block external access to mail server
$SUDO ufw deny 25

# Ask user for RPC server IP address and email address for alerts
ask_and_store "Enter the IP address of the RPC server" "RPC_IP"
ask_and_store "Enter the email address to receive alerts" "EMAIL_ADDRESS"

# Restart services
$SUDO systemctl restart postfix
$SUDO ufw enable

# Create rpc_check.log file
touch rpc_check.log
