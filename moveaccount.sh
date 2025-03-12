#!/bin/bash

source=host1
dest=host2

if [ $# -ne 1 ]; then
    echo "Error: Please provide exactly one email address as an argument."
    echo "Usage: $0 email@address.com"
    exit 1
fi
user="$1"
if [[ "$user" != *"@"* ]]; then
    echo "Error: Invalid email address. Please provide a valid email address."
    exit 1
fi

# Get mailbox size
mbox_size=`zmmailbox -z -m $user gms`
echo "Mailbox size of $user = $mbox_size"

# Capture start time
start_time=$(date +%s)

echo "Starting migration for: $user"
zmmboxmove -a "$user" -f $source -t $dest --sync

migration_status=$?
# Capture end time
end_time=$(date +%s)

# Calculate duration
duration=$((end_time - start_time))
hours=$((duration / 3600))
minutes=$(( (duration % 3600) / 60 ))
seconds=$((duration % 60))

# Extract size value and unit
size_value=$(echo $mbox_size | grep -o '[0-9.]*')
size_unit=$(echo $mbox_size | grep -o '[KMG]B')

# Convert to bytes based on unit
case $size_unit in
    KB)
        size_bytes=$(echo "$size_value * 1024" | bc)
        ;;
    MB)
        size_bytes=$(echo "$size_value * 1024 * 1024" | bc)
        ;;
    GB)
        size_bytes=$(echo "$size_value * 1024 * 1024 * 1024" | bc)
        ;;
    *)
        size_bytes=$size_value
        ;;
esac

# Calculate transfer speed in MB/s
if [ $duration -gt 0 ]; then
    # Convert bytes to MB and divide by duration
    speed_mb=$(echo "scale=2; $size_bytes / 1048576 / $duration" | bc)
else
    speed_mb="N/A"
fi

if [ $migration_status -eq 0 ]; then
    echo "Migration completed successfully."
    echo "Migration duration: $hours hours, $minutes minutes, $seconds seconds"
    echo "Transfer speed: $speed_mb MB/s"
else
    echo "Error occurred during migration."
    exit 1
fi
