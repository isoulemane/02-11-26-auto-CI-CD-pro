
#!/bin/bash

# Exit if any command fails
set -e

echo "===================================="
echo " Starting Nginx Installation"
echo "===================================="

# Update system packages
sudo apt update -y

# Install Nginx
sudo apt install nginx -y

# Enable and start Nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Configure Nginx reverse proxy
echo "Creating Nginx configuration..."

sudo tee /etc/nginx/sites-available/snasnad > /dev/null <<'EOF'
server {
    listen 80;
    server_name snasnad.com www.snasnad.com;

    location / {
        proxy_pass http://127.0.0.1:8080/webapp/;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Enable the Nginx site
sudo ln -sf /etc/nginx/sites-available/snasnad \
/etc/nginx/sites-enabled/snasnad

# Remove default Nginx site
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
echo "Testing Nginx configuration..."

sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Display Nginx status
echo "===================================="
echo " Nginx Installation Completed!"
echo "===================================="

sudo systemctl status nginx --no-pager
