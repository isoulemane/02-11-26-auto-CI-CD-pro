#!/bin/bash

# ============================================================
# AUTOMATIC JENKINS SERVER SETUP
# Amazon Linux 2023
#
# Installs:
#   - Java 21 Corretto
#   - Maven
#   - Git
#   - Jenkins
#
# Configures:
#   - Java 21 as system default
#   - JAVA_HOME = Java 21
#   - Maven -> Java 21
#   - Jenkins -> Java 21
#   - Jenkins service starts automatically
# ============================================================

set -euo pipefail

echo ""
echo "============================================================"
echo "        JENKINS SERVER AUTOMATIC SETUP"
echo "============================================================"
echo ""

# ============================================================
# 1. UPDATE SYSTEM
# ============================================================

echo "[1/12] Updating Amazon Linux..."

sudo dnf update -y

# ============================================================
# 2. INSTALL JAVA 21
# ============================================================

echo ""
echo "[2/12] Installing Java 21..."

sudo dnf install -y \
    java-21-amazon-corretto \
    java-21-amazon-corretto-devel

# Find Java 21 automatically
JAVA_BIN_21="$(find /usr/lib/jvm \
    -type f \
    -path '*/java-21*/bin/java' \
    | head -n 1)"

if [ -z "${JAVA_BIN_21}" ]; then
    echo ""
    echo "ERROR: Java 21 was not found."
    echo ""
    echo "Installed JVMs:"
    ls -la /usr/lib/jvm/
    exit 1
fi

JAVA_HOME_21="$(dirname "$(dirname "${JAVA_BIN_21}")")"

echo ""
echo "Java 21 executable:"
echo "${JAVA_BIN_21}"

echo ""
echo "Java 21 JAVA_HOME:"
echo "${JAVA_HOME_21}"

# ============================================================
# 3. CONFIGURE JAVA 21 AS DEFAULT
# ============================================================

echo ""
echo "[3/12] Configuring Java 21 as the default Java..."

sudo alternatives --install \
    /usr/bin/java \
    java \
    "${JAVA_BIN_21}" \
    21000

sudo alternatives --set java "${JAVA_BIN_21}"

# Configure javac if available
if [ -x "${JAVA_HOME_21}/bin/javac" ]; then

    sudo alternatives --install \
        /usr/bin/javac \
        javac \
        "${JAVA_HOME_21}/bin/javac" \
        21000

    sudo alternatives --set javac \
        "${JAVA_HOME_21}/bin/javac"

fi

# ============================================================
# 4. REMOVE OLD JAVA 17 ENVIRONMENT SETTINGS
# ============================================================

echo ""
echo "[4/12] Checking for old Java 17 environment settings..."

# Remove old Java 17 profile files
for FILE in /etc/profile.d/*.sh; do

    if [ -f "$FILE" ]; then

        if grep -q \
            "java-17-amazon-corretto\|JAVA_HOME.*17" \
            "$FILE" 2>/dev/null; then

            echo "Removing old Java 17 settings from:"
            echo "$FILE"

            sudo sed -i \
                '/java-17-amazon-corretto/d' \
                "$FILE"

            sudo sed -i \
                '/JAVA_HOME.*17/d' \
                "$FILE"

        fi

    fi

done

# Remove Java 17 references from ec2-user files
for FILE in \
    "$HOME/.bashrc" \
    "$HOME/.bash_profile" \
    "$HOME/.profile"
do

    if [ -f "$FILE" ]; then

        sed -i \
            '/java-17-amazon-corretto/d' \
            "$FILE"

        sed -i \
            '/JAVA_HOME.*17/d' \
            "$FILE"

    fi

done

# ============================================================
# 5. CONFIGURE JAVA_HOME GLOBALLY
# ============================================================

echo ""
echo "[5/12] Configuring JAVA_HOME for Java 21..."

sudo tee /etc/profile.d/java21.sh > /dev/null <<EOF
export JAVA_HOME="${JAVA_HOME_21}"
export PATH="\$JAVA_HOME/bin:\$PATH"
EOF

sudo chmod 644 /etc/profile.d/java21.sh

# Configure current shell
export JAVA_HOME="${JAVA_HOME_21}"
export PATH="${JAVA_HOME}/bin:${PATH}"

# ============================================================
# 6. VERIFY JAVA
# ============================================================

echo ""
echo "[6/12] Verifying Java 21..."

echo ""
echo "JAVA_HOME:"
echo "${JAVA_HOME}"

echo ""
echo "Java:"
java -version

# ============================================================
# 7. INSTALL MAVEN
# ============================================================

echo ""
echo "[7/12] Installing Maven..."

sudo dnf install -y maven

# Force Maven to use Java 21
sudo tee /etc/mavenrc > /dev/null <<EOF
JAVA_HOME="${JAVA_HOME_21}"
export JAVA_HOME
EOF

# Verify Maven
echo ""
echo "Maven:"
mvn --version

# ============================================================
# 8. INSTALL GIT
# ============================================================

echo ""
echo "[8/12] Installing Git..."

sudo dnf install -y git

echo ""
echo "Git:"
git --version

# ============================================================
# 9. INSTALL JENKINS REPOSITORY
# ============================================================

echo ""
echo "[9/12] Installing Jenkins repository..."

sudo wget \
    -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import \
    https://pkg.jenkins.io/redhat-stable/jenkins.io-2026.key

# ============================================================
# 10. INSTALL JENKINS
# ============================================================

echo ""
echo "[10/12] Installing Jenkins..."

sudo dnf install -y jenkins

# ============================================================
# 11. FORCE JENKINS TO USE JAVA 21
# ============================================================

echo ""
echo "[11/12] Configuring Jenkins to use Java 21..."

sudo mkdir -p \
    /etc/systemd/system/jenkins.service.d

sudo tee \
    /etc/systemd/system/jenkins.service.d/99-java21.conf \
    > /dev/null <<EOF
[Service]
Environment="JAVA_HOME=${JAVA_HOME_21}"
Environment="JENKINS_JAVA_CMD=${JAVA_BIN_21}"
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable Jenkins at boot
sudo systemctl enable jenkins

# Start Jenkins
sudo systemctl restart jenkins

# Wait for Jenkins
echo ""
echo "Waiting for Jenkins to start..."

sleep 10

# ============================================================
# 12. FINAL VERIFICATION
# ============================================================

echo ""
echo "============================================================"
echo "                 FINAL VERIFICATION"
echo "============================================================"

echo ""
echo "---------------- JAVA ----------------"

echo "JAVA_HOME=${JAVA_HOME}"

java -version

echo ""
echo "---------------- MAVEN ----------------"

mvn --version

echo ""
echo "---------------- GIT ----------------"

git --version

echo ""
echo "---------------- JENKINS ----------------"

sudo systemctl is-enabled jenkins

echo ""

sudo systemctl is-active jenkins

echo ""
echo "---------------- JENKINS ENVIRONMENT ----------------"

sudo systemctl show jenkins \
    --property=Environment \
    --no-pager

echo ""
echo "---------------- JENKINS STATUS ----------------"

sudo systemctl status jenkins \
    --no-pager \
    -l || true

# ============================================================
# CHECK JENKINS JAVA PROCESS
# ============================================================

echo ""
echo "---------------- JENKINS JAVA PROCESS ----------------"

JENKINS_PID="$(sudo systemctl show \
    -p MainPID \
    --value \
    jenkins)"

if [ -n "${JENKINS_PID}" ] && [ "${JENKINS_PID}" != "0" ]; then

    echo "Jenkins PID: ${JENKINS_PID}"

    echo ""
    echo "Jenkins executable:"
    sudo readlink -f \
        "/proc/${JENKINS_PID}/exe" || true

    echo ""
    echo "Jenkins command:"
    sudo ps -o args= \
        -p "${JENKINS_PID}" || true

else

    echo "WARNING: Jenkins does not currently have a running PID."

fi

# ============================================================
# FINAL RESULT
# ============================================================

echo ""
echo "============================================================"
echo "                 SETUP FINISHED"
echo "============================================================"

if sudo systemctl is-active --quiet jenkins; then

    echo ""
    echo "SUCCESS: Jenkins is running."
    echo ""
    echo "Java 21 : CONFIGURED"
    echo "Maven   : CONFIGURED"
    echo "Git     : CONFIGURED"
    echo "Jenkins : RUNNING"
    echo ""

else

    echo ""
    echo "WARNING: Jenkins is NOT running."
    echo ""
    echo "Check the logs with:"
    echo ""
    echo "sudo journalctl -u jenkins -n 100 --no-pager"
    echo ""

fi

echo "============================================================"
