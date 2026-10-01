#JENKINS-AWS-SETUP 


#!/bin/bash

# =========================================================
# Jenkins Setup Script
# Amazon Linux / ec2-user
# Java 21 + Maven + Jenkins
# =========================================================

set -e

echo "=========================================="
echo " Updating system"
echo "=========================================="

sudo dnf update -y


# =========================================================
# Install Java 21
# =========================================================

echo "=========================================="
echo " Installing Java 21"
echo "=========================================="

sudo dnf install -y java-21-amazon-corretto

echo "Java version:"
java -version


# =========================================================
# Make Java 21 the default
# =========================================================

echo "=========================================="
echo " Setting Java 21 as default"
echo "=========================================="

sudo alternatives --set java \
/usr/lib/jvm/java-21-amazon-corretto.x86_64/bin/java

echo "Default Java:"
java -version


# =========================================================
# Install Maven
# =========================================================

echo "=========================================="
echo " Installing Maven"
echo "=========================================="

sudo dnf install -y maven

echo "Maven version:"
mvn -version


# =========================================================
# Install Jenkins repository
# =========================================================

echo "=========================================="
echo " Adding Jenkins repository"
echo "=========================================="

sudo wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import \
https://pkg.jenkins.io/redhat-stable/jenkins.io-2026.key


# =========================================================
# Install Jenkins
# =========================================================

echo "=========================================="
echo " Installing Jenkins"
echo "=========================================="

sudo dnf install -y jenkins


# =========================================================
# Configure Jenkins to use Java 21
# =========================================================

echo "=========================================="
echo " Configuring Jenkins to use Java 21"
echo "=========================================="

sudo mkdir -p /etc/systemd/system/jenkins.service.d

sudo tee /etc/systemd/system/jenkins.service.d/java21.conf > /dev/null <<'EOF'
[Service]
Environment="JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto.x86_64"
Environment="JENKINS_JAVA_CMD=/usr/lib/jvm/java-21-amazon-corretto.x86_64/bin/java"
EOF


# =========================================================
# Reload systemd
# =========================================================

echo "=========================================="
echo " Reloading systemd"
echo "=========================================="

sudo systemctl daemon-reload


# =========================================================
# Enable Jenkins at boot
# =========================================================

echo "=========================================="
echo " Enabling Jenkins"
echo "=========================================="

sudo systemctl enable jenkins


# =========================================================
# Start Jenkins
# =========================================================

echo "=========================================="
echo " Starting Jenkins"
echo "=========================================="

sudo systemctl restart jenkins


# =========================================================
# Check Jenkins status
# =========================================================

echo "=========================================="
echo " Jenkins Status"
echo "=========================================="

sudo systemctl status jenkins --no-pager


# =========================================================
# Display Jenkins Java configuration
# =========================================================

echo "=========================================="
echo " Jenkins Java Configuration"
echo "=========================================="

sudo systemctl show jenkins \
--property=Environment \
--no-pager

echo ""
echo "=========================================="
echo " Installation Complete"
echo "=========================================="

echo "Java:"
java -version

echo ""
echo "Maven:"
mvn -version

echo ""
echo "Jenkins:"
sudo systemctl is-active jenkins

echo ""
echo "Jenkins should now be using Java 21."
echo "=========================================="
