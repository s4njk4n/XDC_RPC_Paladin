#!/bin/bash

# Check if running as root, otherwise run commands with sudo
if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
fi

# Install dependencies
$SUDO apt-get update
$SUDO apt-get install -y curl postfix ufw

# Configure postfix as an Internet Site
echo "postfix postfix/mailname string $(hostname)" | $SUDO debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | $SUDO debconf-set-selections
$SUDO $SUDO dpkg-reconfigure -f noninteractive postfix

# Configure Postfix settings
$SUDO sed -i 's/inet_interfaces = all/inet_interfaces = loopback-only/' /etc/postfix/main.cf
$SUDO sed -i '/mydestination/ s/$/,'$(hostname)'/' /etc/postfix/main.cf
$SUDO systemctl restart postfix

# Configure UFW
$SUDO ufw allow from 127.0.0.1 to any port 25
$SUDO ufw deny from any to any port 25
$SUDO ufw --force enable

# Create rpc_check.log file
touch "$(dirname "$0")/rpc_check.log"

# Execute set_params.sh
SCRIPT_DIR=$(dirname "$0")
"$SCRIPT_DIR/set_params.sh"

