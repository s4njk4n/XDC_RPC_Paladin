#!/bin/bash

# Check if sudo is required
if [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
fi

# Install dependencies
$SUDO apt update
$SUDO apt install -y curl ufw

# Install mail server components
$SUDO apt install -y postfix mailutils

# Configure Postfix as an Internet Site
echo "postfix postfix/mailname string $(hostname)" | $SUDO debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | $SUDO debconf-set-selections
$SUDO $SUDO dpkg-reconfigure -f noninteractive postfix

# Configure Postfix settings
$SUDO postconf -e "inet_interfaces = loopback-only"
$SUDO postconf -e "home_mailbox = Maildir/"
$SUDO postconf -e "smtpd_banner = \$myhostname ESMTP"
$SUDO postconf -e "alias_maps = hash:/etc/aliases"
$SUDO postconf -e "alias_database = hash:/etc/aliases"
$SUDO postconf -e "mydestination = \$myhostname, localhost.\$mydomain, localhost"
$SUDO postconf -e "mynetworks = 127.0.0.0/8"
$SUDO postconf -e "mailbox_size_limit = 0"
$SUDO postconf -e "recipient_delimiter = +"
$SUDO postconf -e "inet_protocols = ipv4"

# Configure ufw
$SUDO ufw allow from 127.0.0.1 to any port 25
$SUDO ufw deny from any to any port 25
$SUDO ufw enable

# Ask for RPC server IP address
read -p "Enter the RPC server IP address: " RPC_IP

# Ask for alert email address
read -p "Enter the email address for alert notifications: " ALERT_EMAIL

# Determine if RPC endpoint uses SSL/TLS encryption
read -p "Does the RPC endpoint use SSL/TLS encryption? (Y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    RPC_URL="https://${RPC_IP}"
else
    RPC_URL="http://${RPC_IP}"
fi

# Store user-defined data fields in settings.txt
cat <<EOF >settings.txt
RPC_IP=${RPC_IP}
ALERT_EMAIL=${ALERT_EMAIL}
RPC_URL=${RPC_URL}
EOF

# Restart services
$SUDO service postfix restart

# Create rpc_check.log file
touch rpc_check.log

echo "Setup completed successfully."
