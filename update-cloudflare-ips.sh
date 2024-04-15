#!/bin/bash

# Set the path where the Cloudflare configuration will be saved
CLOUDFLARE_CONF_PATH="/etc/nginx/cf.conf"

# Create a temporary file to accumulate the configuration
TEMP_FILE=$(mktemp)

# Begin writing the Cloudflare configurations to the temporary file
echo "# Cloudflare IP addresses" > $TEMP_FILE
echo "" >> $TEMP_FILE

# Fetch and append IPv4 addresses to the configuration
echo "# IPv4 addresses" >> $TEMP_FILE
curl -s -L https://www.cloudflare.com/ips-v4 | while read -r ip; do
    echo "set_real_ip_from $ip;" >> $TEMP_FILE
done

# Separate IPv4 and IPv6 sections for clarity
echo "" >> $TEMP_FILE

# Fetch and append IPv6 addresses to the configuration
echo "# IPv6 addresses" >> $TEMP_FILE
curl -s -L https://www.cloudflare.com/ips-v6 | while read -r ip; do
    echo "set_real_ip_from $ip;" >> $TEMP_FILE
done

# Add the real_ip_header directive at the end of the configuration
echo "" >> $TEMP_FILE
echo "real_ip_header CF-Connecting-IP;" >> $TEMP_FILE

# Replace the old Cloudflare configuration file with the new one
# This operation is atomic, ensuring no partial configurations
mv $TEMP_FILE $CLOUDFLARE_CONF_PATH

# Test Nginx configuration for syntax errors and reload if successful
nginx -t && systemctl reload nginx
