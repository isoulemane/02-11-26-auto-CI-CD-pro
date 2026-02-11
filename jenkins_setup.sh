#!/bin/bash

# Update system
sudo apt update -y

# Install Java 17 (Required for Jenkins 2.541+)
sudo apt install openjdk-17-jdk -y
java -version

# Install Maven (ONLY ONE METHOD - using apt)
sudo apt install maven -y
mvn -version

# Add Jenkins key
sudo mkdir -p /etc/apt/keyrings

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

# Add Jenkins repository
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
https://pkg.jenkins.io/debian-stable binary/ | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update -y
sudo apt install jenkins -y

# Start and enable Jenkins
sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Check status
sudo systemctl status jenkins

