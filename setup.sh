#!/bin/bash

# Install dependencies
echo "Installing dependencies..."
apt update
apt install -y curl ssmtp

# Install local mail service (Postfix)
echo "Installing local mail service..."
DEBIAN_FRONTEND=noninteractive apt install -y postfix

# Install ufw
echo "Installing ufw..."
apt install -y ufw

# Configure local mail service
echo "Configuring local mail service..."
sed -i 's/inet_interfaces = all/inet_interfaces = loopback-only/' /etc/postfix/main.cf
service postfix restart

# Configure ufw to allow only local access to mail service
echo "Configuring ufw..."
ufw allow from 127.0.0.1 to any port 25
ufw enable

# User input: RPC server IP address
read -p "Enter the RPC server IP address: " rpc_server_ip

# User input: Email address for alerts
read -p "Enter the email address for alerts: " email_address

# Store user-defined data fields in settings.txt
echo "rpc_server_ip=$rpc_server_ip" > settings.txt
echo "email_address=$email_address" >> settings.txt

touch rpc_check.log

echo "Setup completed successfully!"
