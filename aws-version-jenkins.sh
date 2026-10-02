#!/bin/bash

# =========================================================
# Jenkins Setup Script
# Amazon Linux 2023 / ec2-user
# Java 21 + Maven + Git + Jenkins
# =========================================================

set -euo pipefail

echo ""
echo "========================================================="
echo "        JENKINS SERVER SETUP - AMAZON LINUX 2023"
echo "========================================================="
echo ""

# =========================================================
# 1. UPDATE SYSTEM
# =========================================================

echo "=========================================="
echo " Updating system"
echo "=========================================="

sudo dnf update -y


# =========================================================
# 2. INSTALL JAVA 21
# =========================================================

echo "=========================================="
echo " Installing Java 21 - Amazon Corretto"
echo "=========================================="

sudo dnf install -y java-21-amazon-corretto


# =========================================================
# 3. FIND ACTUAL JAVA 21 BINARY
# =========================================================

echo "=========================================="
echo " Detecting Java 21 installation"
echo "=========================================="

JAVA_BIN_21="$(rpm -ql java-21-amazon-corretto-headless \
    | grep '/bin/java$' \
    | head -n 1)"

if [ -z "${JAVA_BIN_21}" ]; then
    echo "ERROR: Java 21 binary could not be found."
    exit 1
fi

if [ ! -x "${JAVA_BIN_21}" ]; then
    echo "ERROR: Java binary exists but is not executable:"
    echo "${JAVA_BIN_21}"
    exit 1
fi

JAVA_HOME_21="$(dirname "$(dirname "${JAVA_BIN_21}")")"

echo ""
echo "Java 21 binary:"
echo "${JAVA_BIN_21}"

echo ""
echo "Java 21 home:"
echo "${JAVA_HOME_21}"

echo ""
echo "Java 21 version:"
"${JAVA_BIN_21}" -version


# =========================================================
# 4. CONFIGURE JAVA 21 AS SYSTEM DEFAULT
# =========================================================

echo "=========================================="
echo " Setting Java 21 as system default"
echo "=========================================="

sudo alternatives --install \
    /usr/bin/java \
    java \
    "${JAVA_BIN_21}" \
    21000

sudo alternatives --set java "${JAVA_BIN_21}"


# =========================================================
# 5. CONFIGURE JAVAC
# =========================================================

if [ -x "${JAVA_HOME_21}/bin/javac" ]; then

    echo "Configuring javac..."

    sudo alternatives --install \
        /usr/bin/javac \
        javac \
        "${JAVA_HOME_21}/bin/javac" \
        21000

    sudo alternatives --set javac \
        "${JAVA_HOME_21}/bin/javac"

fi


# =========================================================
# 6. VERIFY JAVA
# =========================================================

echo "=========================================="
echo " Verifying Java"
echo "=========================================="

echo "Java location:"
which java

echo ""

echo "Java real path:"
readlink -f "$(which java)"

echo ""

echo "Java version:"
java -version


# =========================================================
# 7. INSTALL MAVEN
# =========================================================

echo "=========================================="
echo " Installing Maven"
echo "=========================================="

sudo dnf install -y maven

echo ""
echo "Maven version:"
mvn --version


# =========================================================
# 8. INSTALL GIT
# =========================================================

echo "=========================================="
echo " Installing Git"
echo "=========================================="

sudo dnf install -y git

echo ""
echo "Git version:"
git --version


# =========================================================
# 9. ADD JENKINS REPOSITORY
# =========================================================

echo "=========================================="
echo " Adding Jenkins repository"
echo "=========================================="

sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import \
    https://pkg.jenkins.io/redhat-stable/jenkins.io-2026.key


# =========================================================
# 10. INSTALL JENKINS
# =========================================================

echo "=========================================="
echo " Installing Jenkins"
echo "=========================================="

sudo dnf install -y jenkins


# =========================================================
# 11. CONFIGURE JENKINS TO USE JAVA 21
# =========================================================

echo "=========================================="
echo " Configuring Jenkins for Java 21"
echo "=========================================="

sudo mkdir -p \
    /etc/systemd/system/jenkins.service.d

sudo tee \
    /etc/systemd/system/jenkins.service.d/99-java21.conf \
    > /dev/null <<EOF
[Service]
Environment="JAVA_HOME=${JAVA_HOME_21}"
Environment="JENKINS_JAVA_CMD=${JAVA_BIN_21}"
EOF


# =========================================================
# 12. RELOAD SYSTEMD
# =========================================================

echo "=========================================="
echo " Reloading systemd"
echo "=========================================="

sudo systemctl daemon-reload


# =========================================================
# 13. ENABLE JENKINS
# =========================================================

echo "=========================================="
echo " Enabling Jenkins"
echo "=========================================="

sudo systemctl enable jenkins


# =========================================================
# 14. START JENKINS
# =========================================================

echo "=========================================="
echo " Starting Jenkins"
echo "=========================================="

sudo systemctl restart jenkins


# =========================================================
# 15. WAIT FOR JENKINS
# =========================================================

echo "=========================================="
echo " Waiting for Jenkins"
echo "=========================================="

sleep 10


# =========================================================
# 16. JENKINS STATUS
# =========================================================

echo "=========================================="
echo " Jenkins Status"
echo "=========================================="

sudo systemctl status jenkins --no-pager || true


# =========================================================
# 17. JENKINS EFFECTIVE ENVIRONMENT
# =========================================================

echo ""
echo "=========================================="
echo " Jenkins Environment"
echo "=========================================="

sudo systemctl show jenkins \
    --property=Environment \
    --no-pager


# =========================================================
# 18. FIND JENKINS PROCESS
# =========================================================

JENKINS_PID="$(sudo systemctl show \
    -p MainPID \
    --value jenkins)"

if [ -n "${JENKINS_PID}" ] && [ "${JENKINS_PID}" != "0" ]; then

    echo ""
    echo "=========================================="
    echo " Jenkins Java Process"
    echo "=========================================="

    echo "Jenkins PID:"
    echo "${JENKINS_PID}"

    echo ""

    echo "Running Java executable:"
    sudo readlink -f \
        "/proc/${JENKINS_PID}/exe" || true

fi


# =========================================================
# 19. FINAL VERIFICATION
# =========================================================

echo ""
echo "========================================================="
echo "                 FINAL VERIFICATION"
echo "========================================================="

echo ""
echo "Java:"
java -version

echo ""
echo "Maven:"
mvn --version

echo ""
echo "Git:"
git --version

echo ""
echo "Jenkins package:"
rpm -q jenkins

echo ""
echo "Jenkins service:"
sudo systemctl is-active jenkins

echo ""
echo "Jenkins port:"
sudo ss -lntp | grep ':8080' || true


# =========================================================
# 20. GET INITIAL ADMIN PASSWORD
# =========================================================

echo ""
echo "========================================================="
echo "              JENKINS INITIAL PASSWORD"
echo "========================================================="

if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then

    echo ""
    echo "Initial Administrator Password:"
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword

else

    echo ""
    echo "Initial password is not available yet."
    echo "Check:"
    echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"

fi


# =========================================================
# COMPLETE
# =========================================================

echo ""
echo "========================================================="
echo "              INSTALLATION COMPLETE"
echo "========================================================="

echo ""
echo "Java Home:"
echo "${JAVA_HOME_21}"

echo ""
echo "Java Binary:"
echo "${JAVA_BIN_21}"

echo ""
echo "Jenkins URL:"
echo "http://YOUR-EC2-PUBLIC-IP:8080"

echo ""
echo "========================================================="
