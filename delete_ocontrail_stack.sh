#!/usr/bin/env bash

stackname=$1

if [ -z "$stackname" ]; then
    echo "stack name not set"
    exit 1
fi

echo "Deleting opencontrail $stackname stack for POC"

aws cloudformation delete-stack --stack-name $stackname 


echo "Wait till opencontrail stack($stackname) is deleted\n"
aws cloudformation wait stack-delete-complete --stack-name $stackname
