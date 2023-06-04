#!/bin/bash

# Check if sudo is required
if [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
fi

# Function to set up cron job
setup_cron() {
    $SUDO crontab -l | { cat; echo "* * * * * ~/XDC_RPC_Check/rpc_check.sh >> ~/XDC_RPC_Check/rpc_check.log 2>&1 &"; } | $SUDO crontab -
    echo "Cron job set up successfully."
}

# Function to cancel cron job
cancel_cron() {
    $SUDO crontab -l | grep -v "~/XDC_RPC_Check/rpc_check.sh" | $SUDO crontab -
    echo "Cron job canceled successfully."
}

# Interactive menu
echo "RPC Schedule"
echo "1. Set up minutely RPC check"
echo "2. Cancel minutely RPC check"
read -p "Enter your choice (1-2): " choice

case $choice in
    1)
        setup_cron
        ;;
    2)
        cancel_cron
        ;;
    *)
        echo "Invalid choice. Exiting..."
        ;;
esac
