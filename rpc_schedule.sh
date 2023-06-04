#!/bin/bash

# Check if sudo is required
if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
fi

# Function to set up cron job
setup_cron_job() {
    $SUDO crontab -l | { cat; echo "* * * * * $HOME/XDC_RPC_Check/rpc_check.sh >/dev/null 2>&1 &"; } | $SUDO crontab -
    echo "Cron job set up successfully."
}

# Function to remove cron job
remove_cron_job() {
    $SUDO crontab -l | grep -v "$HOME/XDC_RPC_Check/rpc_check.sh" | $SUDO crontab -
    echo "Cron job removed successfully."
}

# Interactive menu
echo "RPC Schedule Menu"
echo "1. Set up minutely RPC check"
echo "2. Cancel minutely RPC check"
read -p "Enter your choice: " choice

case $choice in
    1)
        setup_cron_job
        ;;
    2)
        remove_cron_job
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
