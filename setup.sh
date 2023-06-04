#!/bin/bash

# Check if sudo is required
if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
fi

# Install dependencies
$SUDO apt update
$SUDO apt install -y curl postfix ufw

# Configure Postfix
echo "postfix postfix/main_mailer_type select Internet Site" | $SUDO debconf-set-selections
$SUDO dpkg-reconfigure -f noninteractive postfix

# Configure Postfix settings
$SUDO postconf -e "mydestination = localhost.localdomain, localhost"
$SUDO postconf -e "inet_interfaces = loopback-only"

# Configure UFW
$SUDO ufw allow Postfix
$SUDO ufw deny from any to any port 25

# Ask for alert email address
read -p "Enter the email address to send alert emails to: " ALERT_EMAIL

# Save settings to settings.txt
echo "ALERT_EMAIL=$ALERT_EMAIL" >settings.txt
echo "RPC_URL=" >>settings.txt

# Restart services
$SUDO systemctl restart postfix

# Create rpc_check.log file
touch rpc_check.log
