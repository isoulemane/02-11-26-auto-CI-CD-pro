
#!/bin/bash

# Check root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script using: sudo bash docker_setup.sh"
    exit 1
fi

# Update Ubuntu packages
echo "Updating package lists..."
apt update -y

# Install Docker
echo "Installing Docker..."
apt install docker.io -y

# Enable and start Docker
echo "Starting Docker service..."
systemctl enable docker
systemctl start docker

# Add ubuntu user to Docker group
echo "Adding ubuntu to Docker group..."
usermod -aG docker ubuntu

# Verify Docker installation
echo "Checking Docker version..."
docker --version

echo "Checking Docker service..."
systemctl status docker --no-pager

echo "Checking Docker images..."
docker images

echo "Checking Docker containers..."
docker ps

echo "================================"
echo "Docker installation completed!"
echo "================================"
echo "Log out and log back in to apply Docker group permissions."
