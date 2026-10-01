#!/bin/bash

# =========================================================
# Jenkins Setup Script
# Amazon Linux / ec2-user
# Java 21 + Maven + Jenkins
# =========================================================

set -euo pipefail

JAVA_HOME_21="/usr/lib/jvm/java-21-amazon-corretto"
JAVA_BIN_21="${JAVA_HOME_21}/bin/java"

# =========================================================
# Update system
# =========================================================
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

# Sanity check the path we'll use everywhere
if [ ! -x "${JAVA_BIN_21}" ]; then
    echo "ERROR: ${JAVA_BIN_21} not found or not executable."
    echo "Available JVMs:"
    ls -1 /usr/lib/jvm/
    exit 1
fi

echo "Java 21 binary:"
"${JAVA_BIN_21}" -version

# =========================================================
# Make Java 21 the system default
# =========================================================
echo "=========================================="
echo " Setting Java 21 as default"
echo "=========================================="
sudo alternatives --install /usr/bin/java java "${JAVA_BIN_21}" 2100
sudo alternatives --set java "${JAVA_BIN_21}"

# Also pin javac if present
if [ -x "${JAVA_HOME_21}/bin/javac" ]; then
    sudo alternatives --install /usr/bin/javac javac "${JAVA_HOME_21}/bin/javac" 2100
    sudo alternatives --set javac "${JAVA_HOME_21}/bin/javac"
fi

echo "Default Java now:"
java -version

# =========================================================
# Install Maven
# =========================================================
echo "=========================================="
echo " Installing Maven"
echo "=========================================="
sudo dnf install -y maven
mvn -version

# =========================================================
# Add Jenkins repository
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
# NOTE: The RPM may pull in java-17 as a dependency.
#       We don't fight that — we just force Jenkins itself
#       to run on Java 21 via a drop-in override below.
# =========================================================
echo "=========================================="
echo " Installing Jenkins"
echo "=========================================="
sudo dnf install -y jenkins

# =========================================================
# Configure Jenkins to use Java 21
# The drop-in is named 99-java21.conf so it loads LAST
# and overrides any Jenkins-shipped or earlier drop-ins.
# =========================================================
echo "=========================================="
echo " Configuring Jenkins to use Java 21"
echo "=========================================="
sudo mkdir -p /etc/systemd/system/jenkins.service.d

# Remove any old drop-in from previous runs
sudo rm -f /etc/systemd/system/jenkins.service.d/java21.conf

sudo tee /etc/systemd/system/jenkins.service.d/99-java21.conf > /dev/null <<EOF
[Service]
Environment="JAVA_HOME=${JAVA_HOME_21}"
Environment="JENKINS_JAVA_CMD=${JAVA_BIN_21}"
EOF

# =========================================================
# Reload systemd, enable and restart Jenkins
# =========================================================
echo "=========================================="
echo " Reloading systemd"
echo "=========================================="
sudo systemctl daemon-reload

echo "=========================================="
echo " Enabling Jenkins"
echo "=========================================="
sudo systemctl enable jenkins

echo "=========================================="
echo " Restarting Jenkins"
echo "=========================================="
sudo systemctl restart jenkins

# Give it a moment to spin up
sleep 5

# =========================================================
# Verify
# =========================================================
echo "=========================================="
echo " Jenkins Status"
echo "=========================================="
sudo systemctl status jenkins --no-pager || true

echo ""
echo "=========================================="
echo " Jenkins Effective Environment"
echo "=========================================="
sudo systemctl show jenkins --property=Environment --no-pager

# Find the actual PID and its java command
JENKINS_PID="$(systemctl show -p MainPID --value jenkins || true)"
if [ -n "${JENKINS_PID}" ] && [ "${JENKINS_PID}" != "0" ]; then
    echo ""
    echo "Jenkins PID: ${JENKINS_PID}"
    echo "Running Java binary:"
    sudo readlink -f "/proc/${JENKINS_PID}/exe" || true
    echo ""
    echo "Full Jenkins java process (check for java-21 path):"
    ps -o args= -p "${JENKINS_PID}" | tr ' ' '\n' | grep -E 'java|JVM' | head -n 5 || true
fi

# =========================================================
# Summary
# =========================================================
echo ""
echo "=========================================="
echo " Installation Complete"
echo "=========================================="
echo "Java (system default):"
java -version
echo ""
echo "Maven:"
mvn -version
echo ""
echo "Jenkins active:"
sudo systemctl is-active jenkins
echo ""
echo "If the 'Running Java binary' above points to"
echo "${JAVA_HOME_21}/bin/java, Jenkins is on Java 21."
echo "=========================================="
