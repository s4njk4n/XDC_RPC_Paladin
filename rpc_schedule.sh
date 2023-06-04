#!/bin/bash

# Check if running as root, otherwise run with sudo
if [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
fi

# Function to start rpc_check.sh as a background process
start_rpc_check() {
    $SUDO chmod +x ~/XDC_RPC_Check/rpc_check.sh
    $SUDO nohup ~/XDC_RPC_Check/rpc_check.sh >/dev/null 2>&1 &
    echo "rpc_check.sh started running once per minute."
}

# Function to stop rpc_check.sh background process
stop_rpc_check() {
    $SUDO pkill -f "rpc_check.sh"
    echo "rpc_check.sh stopped running."
}

# Interactive menu
while true; do
    echo "Please select an option:"
    echo "1. Start running rpc_check.sh once per minute"
    echo "2. Stop running rpc_check.sh"
    read -p "Enter your choice (1 or 2): " choice

    case $choice in
    1)
        start_rpc_check
        break
        ;;
    2)
        stop_rpc_check
        break
        ;;
    *)
        echo "Invalid choice. Please try again."
        ;;
    esac
done
