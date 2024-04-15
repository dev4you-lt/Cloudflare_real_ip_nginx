
# Cloudflare Real IP Configuration for Nginx

This repository contains a Bash script that automates the process of updating your Nginx configuration to include Cloudflare’s trusted IP ranges. This script ensures that Nginx correctly identifies the real IP address of visitors that come through Cloudflare, improving both the accuracy of logging and security measures like IP-based access control.

## Description

The `update-cloudflare-ips.sh` script fetches the latest IPv4 and IPv6 addresses published by Cloudflare and configures Nginx to use these addresses with the `set_real_ip_from` directive. This setup helps mitigate issues where visitor IP addresses are masked by Cloudflare’s proxies, ensuring that your server sees the visitor's true IP address as if they weren't behind a CDN.

## Features

- Automatically fetches the latest IP ranges from Cloudflare.
- Configures Nginx to recognize real IP addresses from Cloudflare masked IPs.
- Provides atomic updates to Nginx configuration to avoid downtime.
- Includes Nginx configuration testing before applying changes.

## Prerequisites

- A Unix-like environment with Bash
- Nginx installed on your server
- Curl must be installed to fetch IP ranges from Cloudflare
- Sudo or root access to modify Nginx configurations and reload the server

## Installation

1. Clone the repository to your desired location:
   ```bash
   git clone https://github.com/dev4you-lt/cloudflare-nginx-ip-updater.git
   ```
2. Navigate to the directory containing the script:
   ```bash
   cd cloudflare-nginx-ip-updater
   ```
3. Make the script executable:
   ```bash
   chmod +x update-cloudflare-ips.sh
   ```

## Usage

To update your Nginx configuration with the latest Cloudflare IPs, run the script:
```bash
sudo ./update-cloudflare-ips.sh
```
This command must be run as root or with sudo to ensure it has the necessary permissions to modify Nginx configuration files and reload the server.

## Scheduled Updates

To keep your configuration up to date automatically, consider adding the script to your crontab:
```cron
0 12 * * * /path/to/update-cloudflare-ips.sh
```
This cron job runs the script daily at noon, fetching the latest IP ranges and updating the configuration accordingly.

## Contributions

Contributions are welcome! If you have improvements or bug fixes, please feel free to fork the repository and submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you encounter any issues or have questions about using the script, please file an issue in the GitHub repository.
