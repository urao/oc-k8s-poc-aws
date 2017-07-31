# opencontrail-k8s-poc-aws
Deploy opencontrail cloud on Ubuntu 16.04 OS [1 k8s-master, 1 k8s-node] as POC on AWS

Steps to deploy this opencontrail+k8s on AWS

Pre-requisties:
--------------
1. AWS account
2. On host from where these scripts will be executed, install the below packages
   1. apt-get -y install python-pip ansible git awscli
3. Configure, aws with credentials, access_key and secret_access_key


Steps to deploy contrail cloud:
-------------------------------
1. Git clone the repo
2. Change directory 'cd opencontrail-poc-aws'
3. Copy the opencontrail package under ansible/files folder
   1. Example, contrail-install-packages_3.2.2.0-33mitaka_all.deb
4. Run ./create_keypair.sh [Create KeyPair]
5. Populate contrail-parameters.json file with required values, refer to sample file
6. Create VPC, Subnet and 2 EC2 instances with host OS Ubuntu 14.04.4
   1. Run ./create_ocontrail_stack.sh <stack-name> ocontrail cstack-parameters
7. Verify cloudformation stack and populate cluster information to run deploy contrail
   1. Run ./verify_ocontrail_stack.sh <stack-name>
8. Modify contrail package name in ansible/playbook/inventory/group_vars/all.yml
9. Run ansible playbook to deploy Opencontrail Cloud
   1. Change directory 'cd ansible/playbook'
   2. Run 'ansible-playbook -i inventory/ contrail.yml' 
10. Connect to contrail-webui, using public ip address of contrailc EC2 instance


Delete contrail cloud stack:
---------------------------
1. Run, ./delete_ocontrail_stack.sh <stack_name>
2. Run, ./delete_keypair.sh
