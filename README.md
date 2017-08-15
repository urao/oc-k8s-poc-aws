# opencontrail-k8s-poc-aws
Deploy opencontrail cloud on Ubuntu 16.04 OS [1 k8s-master, 1 k8s-node] as POC on AWS

Steps to deploy opencontrail+k8s on AWS

Pre-requisties:
--------------
1. AWS account
2. On host from where these scripts will be executed, install the below packages
   1. apt-get -y install python-pip ansible git awscli
3. Configure, aws with credentials, access_key and secret_access_key


Steps to deploy contrail cloud:
-------------------------------
1. Git clone the repo
2. Change directory 'cd opencontrail-k8s-poc-aws'
3. Copy the opencontrail docker packages and ansible packages under ansible/files folder
   1. Below is the example
   2. contrail_package: contrail-kubernetes-docker-images_4.0.0.0-20.tgz
   3. contrail_ansible_package : contrail-ansible-4.0.0.0-20.tar.gz
   4. The above packages can be found by doing the below steps:
      1. Download contrail-kubernetes-docker_4.0.0.0-20_xenial.tgz, from juniper download site[http://www.juniper.net/support/downloads/?p=contrail#sw]
      2. Untar the above package to get contrail_package, tar -zxvf contrail-kubernetes-docker_4.0.0.0-20_xenial.tgz
      3. Untar contrail-networking-tools_4.0.0.0-20.tgz, to get contrail_ansible_package 
4. Run ./create_keypair.sh [Create KeyPair]
5. Populate cstack-parameters.json located at (cloudformation/cluster) file with name of the EC2 instances (CCName1, CCName2)
6. Create VPC, Subnet and 2 EC2 instances with host OS Ubuntu 16.04
   1. Run ./create_ocontrail_stack.sh \<stack-name\> ocontrail.json cstack-parameters.json
8. Wait for couple of minutes for the EC2 instances to come up
9. Verify cloudformation stack and populate cluster information 
   1. Run ./verify_ocontrail_stack.sh \<stack-name\>
10. Modify contrail_package, contrail_ansible_package and contrail_version parameters in ansible/playbooks/inventory/group_vars/all.yml file
11. Run ansible playbook to deploy opencontrail+k8s
   1. Change directory 'cd ansible/playbooks'
   2. Run 'ansible-playbook -i inventory/ k8s-contrail.yml' 
12. Connect to contrail-webui, using public IP address of CCName1 EC2 instance with credentials admin/contrail123


Delete contrail cloud stack:
---------------------------
1. Run, ./delete_ocontrail_stack.sh <stack_name>
2. Run, ./delete_keypair.sh
