#!/bin/bash


terraform refresh
# Get public IPs from Terraform outputs
master_controller_ip=$(terraform output -json public_ips | jq -r '.["Master-controller"]')
kube_master_ip=$(terraform output -json public_ips | jq -r '.["Kube-Master"]')
kube_worker1_ip=$(terraform output -json public_ips | jq -r '.["Kube-Worker1"]')
kube_worker2_ip=$(terraform output -json public_ips | jq -r '.["Kube-Worker2"]')



# Write the SSH configuration to a text file
echo "[MasterController]" > hosts_config.txt
echo "ubuntu@$master_controller_ip" >> hosts_config.txt
echo "[KubeMaster]" >> hosts_config.txt
echo "ubuntu@$kube_master_ip" >> hosts_config.txt
echo "[KubeWorkers]" >> hosts_config.txt
echo "ubuntu@$kube_worker1_ip" >> hosts_config.txt
echo "ubuntu@$kube_worker2_ip" >> hosts_config.txt

echo "Hosts configuration written to hosts_config.txt"

#sleep 10
#ansible all -i hosts_config.txt --private-key=./ohio.pem -m ansible.builtin.copy -a "src=/home/praveen/.ssh/id_rsa.pub dest=/home/ubuntu/.ssh/authorized_keys" -e "ansible_user=ubuntu"

#sleep 10
#ansible all -i hosts_config.txt -m ping
