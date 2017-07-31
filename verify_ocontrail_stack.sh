#!/usr/bin/env bash

stackname=$1

if [ -z "$stackname" ]; then
    echo "stack name not set"
    exit 1
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo "Verifying OpenContrail $stackname stack for POC"
echo "Checking wether EC2 instances are UP and RUNNING"
echo

master=$(cat cloudformation/cluster/cstack-parameters.json | grep CCName1 -A2 | awk '{print $2}' | sed -n 2p)
node=$(cat cloudformation/cluster/cstack-parameters.json | grep CCName2 -A2 | awk '{print $2}' | sed -n 2p)

echo $master
echo $node

aws ec2 wait instance-running --filters "Name=tag:Name,Values="$master""
aws ec2 wait instance-running --filters "Name=tag:Name,Values="$node""

echo "EC2 insances are RUNNING"
echo

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

echo "master_hostname: $master">>$DIR/ansible/playbooks/inventory/group_vars/all.yml
echo "node_hostname: $node">>$DIR/ansible/playbooks/inventory/group_vars/all.yml

echo "master_ip: $master_pip">>$DIR/ansible/playbooks/inventory/group_vars/all.yml
echo "node_ip: $node01_pip">>$DIR/ansible/playbooks/inventory/group_vars/all.yml
