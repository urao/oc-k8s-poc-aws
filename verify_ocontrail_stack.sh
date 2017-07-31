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

aws ec2 wait instance-running --filters "Name=tag:Name,Values=contrailc"
aws ec2 wait instance-running --filters "Name=tag:Name,Values=compute01"

echo "EC2 insances are RUNNING"
echo

echo "[contrailc]">>$DIR/ansible/playbook/inventory/hosts
contrailc_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=contrailc" | grep PublicIpAddress | cut -d':' -f2 | tr -d '", ')
echo "$contrailc_ip">>$DIR/ansible/playbook/inventory/hosts
echo "">>$DIR/ansible/playbook/inventory/hosts

echo "[compute01]">>$DIR/ansible/playbook/inventory/hosts
compute01_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=compute01" | grep PublicIpAddress | cut -d':' -f2 | tr -d '", ')
echo "$compute01_ip">>$DIR/ansible/playbook/inventory/hosts
echo "">>$DIR/ansible/playbook/inventory/hosts

#echo "ContrailC and Compute01 IP.................."
#echo ContrailC: "${contrailc_ip}"
#echo Compute01: "${compute01_ip}"

# Update testbed.py file with private address
contrailc_pip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=contrailc" | grep "\<PrivateIpAddress\>" | cut -d':' -f2 | tr -d '", ' | sort -u)

compute01_pip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=compute01" | grep "\<PrivateIpAddress\>" | cut -d':' -f2 | tr -d '", ' | sort -u)

#echo ContrailCp: "${contrailc_pip}"
#echo Compute01p: "${compute01_pip}"

sed -i "s/1.1.1.1/$contrailc_pip/" $DIR/ansible/files/testbed_single.py
sed -i "s/1.1.1.2/$compute01_pip/" $DIR/ansible/files/testbed_single.py
