#!/bin/bash

# Define the haproxy configuration file location
HAPROXY_CFG="/etc/haproxy/haproxy.cfg"

# Clean up existing socat processes
echo "Stopping existing socat processes..."
pkill -f "socat UDP" 2>/dev/null || echo "No socat processes found."

# Parse the haproxy.cfg for UDP forwarding rules
grep -E "use_backend backend_[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+_[0-9]+ if \{ dst [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ \} acl_p_[0-9]+" "$HAPROXY_CFG" | while read -r line; do    if [[ $line =~ backend_([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)_([0-9]+).*dst[[:space:]]([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*acl_p_([0-9]+) ]]; then
        DEST_IP="${BASH_REMATCH[1]}"
        DEST_PORT="${BASH_REMATCH[2]}"
        SRC_IP="${BASH_REMATCH[3]}"
        SRC_PORT="${BASH_REMATCH[4]}"

        # Start a socat process for UDP forwarding
        echo "Starting socat for ${SRC_IP}:${SRC_PORT} -> ${DEST_IP}:${DEST_PORT}"
        nohup socat UDP4-LISTEN:${SRC_PORT},reuseaddr,fork UDP4:${DEST_IP}:${DEST_PORT} > /dev/null 2>&1 &
    fi
done

echo "UDP forwarding rules applied using socat."
