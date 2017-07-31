#!/usr/bin/env bash

echo "Delete KeyPair"
aws ec2 delete-key-pair --key-name ocontrail
rm -rf ocontrail.pem
