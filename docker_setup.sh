#!/bin/bash
sudo apt update -y
sudo su
apt update
sudo apt install docker.io -y
usermod -aG docker ubuntu
systemctl start docker
su ubuntu
docker images
docker ps

