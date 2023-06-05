#!/bin/bash

# Check if running as root, otherwise run commands with sudo
if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
fi

# Function to check if crontab exists
check_crontab() {
    local crontab_status=$($SUDO crontab -l 2>/dev/null)
    if [ -z "$crontab_status" ]; then
        $SUDO crontab -l > /dev/null 2>&1
    fi
}

# Interactive menu
while true; do
    echo "-------------------------"
    echo "RPC Schedule Menu"
    echo "-------------------------"
    echo "1. Set server to run rpc_check.sh every minute"
    echo "2. Cancel rpc_check.sh running every minute"
    echo "3. Exit"
    echo "-------------------------"
    read -p "Enter your choice (1-3): " choice

    case $choice in
        1)
            check_crontab
            if [ $? -eq 0 ]; then
                # Add entry to crontab to run rpc_check.sh every minute
                $SUDO sh -c "echo '* * * * * /bin/bash $(dirname "$0")/rpc_check.sh >> $(dirname "$0")/rpc_check.log' >> /etc/crontab"
                echo "RPC check scheduled to run every minute."
                break
            else
                # Create crontab and add the entry to run rpc_check.sh every minute
                echo "* * * * * /bin/bash $(dirname "$0")/rpc_check.sh >> $(dirname "$0")/rpc_check.log" | $SUDO crontab -
                echo "Crontab created and RPC check scheduled to run every minute."
                break
            fi
            ;;
        2)
            check_crontab
            if [ $? -eq 0 ]; then
                # Remove entry from crontab that runs rpc_check.sh every minute
                $SUDO sed -i '/rpc_check.sh/d' /etc/crontab
                echo "RPC check scheduling canceled."
                break
            else
                echo "No crontab exists."
                break
            fi
            ;;
        3)
            exit
            ;;
        *)
            echo "Invalid choice. Please enter a number between 1 and 3."
            ;;
    esac

    echo ""
done
