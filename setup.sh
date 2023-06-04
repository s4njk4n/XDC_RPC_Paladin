#!/bin/bash

MAIL_SETTINGS_FILE="mail_settings.txt"
SMTP_PORT="25"

# Function to install dependencies
install_dependencies() {
    echo "Installing curl..."
    sudo apt-get update
    sudo apt-get install -y curl
}

# Function to configure SMTP and Postfix using mail settings file
configure_email() {
    echo "Configuring SMTP and Postfix..."

    # Install and configure SMTP and Postfix
    echo "Installing and configuring SMTP and Postfix..."
    sudo debconf-set-selections <<< "postfix postfix/mailname string $rpc_ip_address"
    sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
    sudo apt-get install -y postfix mailutils

    # Use local SMTP server settings
    smtp_host="localhost"

    # Save the mail settings to the file
    echo "SMTP_HOST=$smtp_host" > "$MAIL_SETTINGS_FILE"
    echo "SMTP_PORT=$SMTP_PORT" >> "$MAIL_SETTINGS_FILE"
    echo "RPC_IP_ADDRESS=$rpc_ip_address" >> "$MAIL_SETTINGS_FILE"
    echo "EMAIL_ADDRESS_TO=$email_address_to" >> "$MAIL_SETTINGS_FILE"

    # Configure firewall to block external access to SMTP port
    sudo ufw deny "$SMTP_PORT"
}

# Main script
echo "Running setup.sh..."
install_dependencies

# Set up IP address of the RPC server
read -p "Enter the IP address of the RPC server: " rpc_ip_address
echo

configure_email

echo "Setup completed successfully."

