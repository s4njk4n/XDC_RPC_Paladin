#!/bin/bash

# Function to run rpc_check.sh once per minute in the background
run_rpc_check() {
    while true; do
        ./rpc_check.sh &
        sleep 60
    done
}

# Function to stop the execution of rpc_check.sh
stop_rpc_check() {
    pkill -f rpc_check.sh
    echo "rpc_check.sh execution stopped."
}

# Main script
echo "Welcome to the RPC Check Setup!"

# Prompt the user for the desired action
while true; do
    read -p "Choose an option:
1) Run rpc_check.sh once per minute on the server
2) Stop rpc_check.sh execution
3) Exit
Enter your choice (1-3): " choice

    # Handle the user's choice
    case $choice in
        1)
            echo "Running rpc_check.sh once per minute on the server..."
            run_rpc_check &
            echo "rpc_check.sh will continue to run once every minute even after you log out."
            ;;
        2)
            echo "Stopping rpc_check.sh execution..."
            stop_rpc_check
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please choose a valid option."
            ;;
    esac
done

