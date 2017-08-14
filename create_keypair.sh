#!/usr/bin/env bash

keyfilename="ocontrail"

echo -e "Creating aws keypair and copy it locally\n"

#create if it does not exists
aws ec2 create-key-pair --key-name $keyfilename --query 'KeyMaterial' --output text > $keyfilename.pem
chmod 400 $keyfilename.pem

export ANSIBLE_HOST_KEY_CHECKING=False
