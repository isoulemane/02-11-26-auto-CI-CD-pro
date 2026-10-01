#!/bin/bash

# Update system
sudo dnf update -y

# Install Docker
sudo dnf install -y docker

# Add ec2-user to Docker group
sudo usermod -aG docker ec2-user

# Start Docker
sudo systemctl start docker

# Enable Docker at boot
sudo systemctl enable docker

# Verify Docker service
sudo systemctl status docker --no-pager

# Verify Docker installation
sudo docker --version
sudo docker images
sudo docker ps
