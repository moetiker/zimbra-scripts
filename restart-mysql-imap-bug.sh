#!/bin/bash
# Path to the log file
LOG_FILE="/opt/zimbra/log/myslow.log"
# File to track the last restart time
LAST_RESTART_FILE="/tmp/mysql_last_restart"

# Check if the log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File $LOG_FILE does not exist."
    exit 1
fi

# Function to restart MySQL server with cooldown
restart_mysql_if_needed() {
    current_time=$(date +%s)
    
    # Check if the last restart file exists
    if [ -f "$LAST_RESTART_FILE" ]; then
        last_restart=$(cat "$LAST_RESTART_FILE")
        time_diff=$((current_time - last_restart))
        
        # Only restart if 5 minutes (300 seconds) have passed since last restart
        if [ "$time_diff" -ge 300 ]; then
            echo "$(date): Restarting MySQL server due to long log line (${#1} chars)"
            mysql.server restart
            echo "$current_time" > "$LAST_RESTART_FILE"
        else
            echo "$(date): Long line detected but cooling down (${#1} chars). Next restart available in $((300 - time_diff)) seconds."
        fi
    else
        # First run, no previous restart
        echo "$(date): Restarting MySQL server due to long log line (${#1} chars)"
        mysql.server restart
        echo "$current_time" > "$LAST_RESTART_FILE"
    fi
}

# Use tail -f to follow the file as it grows
# For each new line, check if it has more than 50000 characters
tail -f "$LOG_FILE" | while IFS= read -r line; do
    # Get the length of the line
    length=${#line}

    # Check if line exceeds threshold and trigger restart if needed
    if [ "$length" -gt 500000 ]; then
        echo "$(date): Length: $length chars | Line: ${line:0:100}..."
        echo restart_mysql_if_needed "$line"
        restart_mysql_if_needed "$line"
    fi
done
