#!/bin/bash
###########

# Updating OS
dnf update --security -y;

sudo dnf install -y python3 ansible wget unzip git dos2unix nc tmux yum-utils bind-utils;

# Preparing FS
echo -e "\nPreparing FS"
sudo sgdisk -n 0:0:0 /dev/vdd
sudo mkfs.xfs /dev/vdd1
sudo mkdir /storage
sudo echo "/dev/vdd1       /storage       xfs     defaults        0       0" >> /etc/fstab
sudo mount -a
echo -e "\nListing block devices:"
sudo lsblk;
echo -e "\nChecking the mount sizes:"
sudo df -h;

# Installing IBM CLI
echo -e "\nInstalling IBM CLI plugins and needed packages"
sudo dnf  install jq perl-JSON-PP -y
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
ibmcloud plugin install vpc-infrastructure
ibmcloud plugin install schematics
ibmcloud plugin update
ibmcloud -v

# Installing Terraform
echo -e "\nInstalling Terraform"
wget https://releases.hashicorp.com/terraform/1.1.9/terraform_1.1.9_linux_amd64.zip -P /tmp/
unzip /tmp/terraform_1.1.9_linux_amd64.zip -d /usr/local/bin
terraform -v

# Preparing Ansible
echo -e "\nSetting ANSIBLE_HOST_KEY_CHECKING to False"
echo "export ANSIBLE_HOST_KEY_CHECKING=False" >> ~/.bash_profile
cp /etc/ansible/ansible.cfg /etc/ansible/ansible.cfg.original.backup

echo "[defaults]
remote_user = root
host_key_checking = False
log_path = /var/log/ansible.log
callback_whitelist = profile_tasks
[ssh_connection]
ssh_args = -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
transfer_method = smart" > /etc/ansible/ansible.cfg

# Adding Storage user
mkdir /storage/.ssh && cp .ssh/authorized_keys /storage/.ssh/
sudo useradd -c "Storage sftp user" storage -d /storage -M -s "/bin/bash"; sudo chown storage -R /storage
chown storage -R /storage/

# Configuring SSH Server
echo "ClientAliveInterval 1200" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 10" >> /etc/ssh/sshd_config
echo "TCPKeepAlive yes" >> /etc/ssh/sshd_config
sed -i "s/#MaxSessions 10/MaxSessions 50/" /etc/ssh/sshd_config
sed -i "s/X11Forwarding yes/X11Forwarding no/" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin yes/PermitRootLogin prohibit-password/" /etc/ssh/sshd_config
sed -i "s/#AllowAgentForwarding yes/AllowAgentForwarding no/" /etc/ssh/sshd_config
echo "MaxStartups 50:30:80"  >> /etc/ssh/sshd_config
echo "AllowStreamLocalForwarding no"  >> /etc/ssh/sshd_config
echo 'AuthenticationMethods publickey' >> /etc/ssh/sshd_config
sudo service sshd reload
