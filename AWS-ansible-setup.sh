#!/bin/bash
set -e

# ==========================================
# AWS EC2 Amazon Linux 2023
# ec2-user: Ansible + Python venv + Docker SDK
# ==========================================

echo "=========================================="
echo "Updating system packages"
echo "=========================================="

sudo dnf update -y

# ==========================================
# 1. Install required packages
# ==========================================

echo "=== Installing Python and development tools ==="

sudo dnf install -y \
    python3 \
    python3-pip \
    python3-devel \
    gcc \
    git \
    sshpass

# ==========================================
# 2. Install Ansible
# ==========================================

echo "=========================================="
echo "Installing Ansible"
echo "=========================================="

sudo dnf install -y ansible

echo "=== Ansible version ==="
ansible --version

# ==========================================
# 3. Install Python virtual environment
# ==========================================

echo "=========================================="
echo "Installing Python venv"
echo "=========================================="

sudo dnf install -y python3.11 python3.11-pip

# ==========================================
# 4. Create Python virtual environment
# ==========================================

echo "=========================================="
echo "Creating Python virtual environment"
echo "=========================================="

cd /home/ec2-user

if [ ! -d "/home/ec2-user/venv" ]; then
    python3 -m venv /home/ec2-user/venv
fi

# ==========================================
# 5. Activate virtual environment
# ==========================================

source /home/ec2-user/venv/bin/activate

# ==========================================
# 6. Upgrade pip
# ==========================================

echo "=========================================="
echo "Upgrading pip"
echo "=========================================="

python -m pip install --upgrade pip

# ==========================================
# 7. Install Docker Python SDK
# ==========================================

echo "=========================================="
echo "Installing Docker Python SDK"
echo "=========================================="

python -m pip install docker

# ==========================================
# 8. Verify installation
# ==========================================

echo "=========================================="
echo "Installation complete"
echo "=========================================="

echo ""
echo "Python:"
python --version

echo ""
echo "Ansible:"
ansible --version

echo ""
echo "Docker Python SDK:"
python -c "import docker; print('Docker SDK:', docker.__version__)"

echo ""
echo "Virtual environment:"
echo "/home/ec2-user/venv"

echo ""
echo "=========================================="
echo "DONE"
echo "=========================================="
