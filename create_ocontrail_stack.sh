#!/usr/bin/env bash

stackname=$1
templatefile=$2
parametersfile=$3

#check if there are 3 arguments
if [ $# -eq 3 ]; then
   if [ -z "$stackname" ]; then
       echo "stack name not set"
       exit 1
   fi
   
   if [ -z "$templatefile" ]; then
       echo "template file not set"
       exit 1
   fi
   
   if [ -z "$parametersfile" ]; then
       echo "parameters file not set"
       exit 1
   fi
else
   echo "Usage: $0 [stackname] [cftemplatefilename] [cfparameterfilename]"
   exit 1
fi

echo -e "Creating opencontrail stack($stackname) for POC\n"

aws cloudformation create-stack \
    --stack-name $stackname  \
    --capabilities="CAPABILITY_IAM" \
    --template-body file://cloudformation/cluster/$templatefile \
    --parameters file://cloudformation/cluster/$parametersfile

echo -e "Wait till the stack($stackname) is created\n"
aws cloudformation wait stack-create-complete --stack-name $stackname && aws cloudformation describe-stacks --stack-name $stackname
