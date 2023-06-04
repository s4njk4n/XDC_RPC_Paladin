#!/bin/bash

# Interactive menu
echo "Select an option:"
echo "1. Schedule 'rpc_check.sh' to run once per minute"
echo "2. Cancel the minutely running of 'rpc_check.sh'"
read -p "Option: " option

case $option in
  1)
    # Schedule 'rpc_check.sh' to run once per minute
    echo "*/1 * * * * $(pwd)/rpc_check.sh >> rpc_check.log" | crontab -
    echo "Scheduled 'rpc_check.sh' to run once per minute"
    ;;
  2)
    # Cancel the minutely running of 'rpc_check.sh'
    crontab -l | grep -v "$(pwd)/rpc_check.sh" | crontab -
    echo "Cancelled the minutely running of 'rpc_check.sh'"
    ;;
  *)
    echo "Invalid option"
    ;;
esac
