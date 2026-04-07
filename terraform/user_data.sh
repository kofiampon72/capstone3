#!/bin/bash
set -e

# Log all output to a file for debugging
exec > /var/log/user_data.log 2>&1
echo "Starting user_data.sh at $(date)"

# Update system packages
apt-get update -y
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Add ubuntu user to docker group so it can run docker without sudo
usermod -aG docker ubuntu

# Install Docker Compose plugin
apt-get install -y docker-compose-plugin

# Install git and other utilities
apt-get install -y git nginx certbot python3-certbot-nginx

# Install Node Exporter (for host-level metrics)
useradd --no-create-home --shell /bin/false node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvf node_exporter-1.7.0.linux-amd64.tar.gz
cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create systemd service for node_exporter so it auto-starts on reboot
cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

# Create the application directory
mkdir -p /opt/dumbbudget
cd /opt/dumbbudget

# Write the environment file with the PIN from Terraform variable
cat > .env << EOF
DUMBBUDGET_PIN=${dumbbudget_pin}
BASE_URL=http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
CURRENCY=USD
SITE_TITLE=DumbBudget
GRAFANA_PASSWORD=admin
NODE_ENV=production
EOF

# Set correct ownership
chown -R ubuntu:ubuntu /opt/dumbbudget

echo "user_data.sh complete at $(date)"