#!/usr/bin/env bash

stackname=$1

#check if there are enough arguments
if [ $# -eq 1 ]; then
   if [ -z "$stackname" ]; then
       echo "stack name not set"
       exit 1
   fi
else
   echo "Usage: $0 [stackname]"
   exit 1
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo -e "Verifying OpenContrail $stackname stack for POC\n"
echo -e "Checking wether EC2 instances are UP and RUNNING\n"
echo

master=$(cat cloudformation/cluster/cstack-parameters.json | grep CCName1 -A2 | awk '{print $2}' | sed -n 2p)
node=$(cat cloudformation/cluster/cstack-parameters.json | grep CCName2 -A2 | awk '{print $2}' | sed -n 2p)

echo $master
echo $node

aws ec2 wait instance-running --filters "Name=tag:Name,Values="$master""
aws ec2 wait instance-running --filters "Name=tag:Name,Values="$node""

echo -e "EC2 insances are RUNNING\n"
echo

# delete hosts file
rm -rf $DIR/ansible/playbooks/inventory/hosts

echo "[master]">>$DIR/ansible/playbooks/inventory/hosts
master_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$master" | grep PublicIpAddress | cut -d':' -f2 | tr -d '", ')
echo "$master_ip     ansible_connection=ssh      ansible_ssh_pass=contrail123">>$DIR/ansible/playbooks/inventory/hosts
echo "">>$DIR/ansible/playbooks/inventory/hosts

echo "[nodes]">>$DIR/ansible/playbooks/inventory/hosts
node01_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$node" | grep PublicIpAddress | cut -d':' -f2 | tr -d '", ')
echo "$node01_ip     ansible_connection=ssh      ansible_ssh_pass=contrail123">>$DIR/ansible/playbooks/inventory/hosts
echo "">>$DIR/ansible/playbooks/inventory/hosts

echo "Master and Node IP"
echo Master: "${master_ip}"
echo Node: "${node01_ip}"

# Update with private address
master_pip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$master" | grep "\<PrivateIpAddress\>" | cut -d':' -f2 | tr -d '", ' | sort -u)

node01_pip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$node" | grep "\<PrivateIpAddress\>" | cut -d':' -f2 | tr -d '", ' | sort -u)

echo Masterp: "${master_pip}"
echo Nodep: "${node01_pip}"

# delete all.yml file
rm -rf $DIR/ansible/playbooks/inventory/group_vars/all.yml

# create new one
cat > $DIR/ansible/playbooks/inventory/group_vars/all.yml <<EOF
###################################################
# Ansible specific vars
##

# ansible connection details
ansible_user: root
ansible_connection: ssh
ansible_ssh_pass: contrail123
host_key_checking: false

###################################################
# Common settings for contrail
##

# contrail package
# example 
#contrail_package: contrail-kubernetes-docker-images_4.0.0.0-20.tgz
#contrail_ansible_package : contrail-ansible-4.0.0.0-20.tar.gz 
#contrail_version: 4.0.0.0-20

contrail_package:
contrail_ansible_package: 
contrail_version: 

EOF

echo "master_hostname: $(sed -e 's/^"//' -e 's/"$//' <<<"$master")">>$DIR/ansible/playbooks/inventory/group_vars/all.yml
echo "node_hostname: $(sed -e 's/^"//' -e 's/"$//' <<<"$node")">>$DIR/ansible/playbooks/inventory/group_vars/all.yml
echo "">>$DIR/ansible/playbooks/inventory/group_vars/all.yml

echo "master_ip: $master_pip">>$DIR/ansible/playbooks/inventory/group_vars/all.yml
echo "node_ip: $node01_pip">>$DIR/ansible/playbooks/inventory/group_vars/all.yml
echo "">>$DIR/ansible/playbooks/inventory/group_vars/all.yml
