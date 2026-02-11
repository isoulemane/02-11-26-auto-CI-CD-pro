#!/bin/bash
set -e

# ==============================
# 1️⃣ Update system packages
# ==============================
sudo apt update -y

# ==============================
# 2️⃣ Install Ansible system-wide
# ==============================
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
ansible --version

# ==============================
# 3️⃣ Install Python venv support
# ==============================
sudo apt install -y python3-venv

# ==============================
# 4️⃣ Create a Python virtual environment
# ==============================
cd ~
python3 -m venv venv

# ==============================
# 5️⃣ Activate the virtual environment
# ==============================
source ~/venv/bin/activate

# ==============================
# 6️⃣ Upgrade pip inside the venv
# ==============================
pip install --upgrade pip

# ==============================
# 7️⃣ Install Docker Python SDK inside venv
# ==============================
pip install docker

# ==============================
# 8️⃣ Verify installations
# ==============================
echo "Python version:"
python --version
echo "Pip packages:"
pip list
echo "Docker SDK check:"
python -c "import docker; print('Docker SDK OK')"
echo "Ansible version check:"
ansible --version

# ==============================
# ✅ Finished
# ==============================
echo "Setup complete! Remember to activate venv with:"
echo "source ~/venv/bin/activate"
 

