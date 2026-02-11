sudo apt update
sudo hostnamectl set-hostname docker-server
logout
touch Dockerfie hosts playbook.yaml jenkins_setup.sh docker_setup.sh ansible_setup.sh
ls-l
ls -l
vi Dockerfile
vi ansible_setup.sh
vi playbook.sh
vi docker_setup.sh
vi jenkins_setup.sh
vi ansible_setup.sh
sudo bash ansible_setup.sh
ssh-keygen
cat .ssh/id_rsa.pub
sudo vi /etc/ssh/sshd_config
sudo systemctl restart sshd
sudo systemctl enable ssh
ssh-keygen
cat .ssh/id_rsa.pub
sudo systemctl restart sshd
sudo systemctl enable ssh
vi hosts
sudo vi /etc/ssh/sshd_config ansible-playbook -i hosts playbook.yaml
