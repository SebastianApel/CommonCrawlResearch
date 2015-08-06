#!/bin/bash

#
# Helper script for aws
#
# - Starts instance
# - Waits
# - SSHs to it
#
#

# Echo command lines executed
set -v

# Start instance
aws ec2 run-instances --image-id ami-a8221fb5 --count 1 --instance-type t2.micro --key-name MyKeyPair --security-groups SecurityGroup1

# Wait until machine has started
sleep 30

# Query the public IP address of the instance
IPADDR=`aws ec2 describe-instances | grep PublicIpAddress | awk 'BEGIN{FS="\""}{print $4}'`
echo $IPADDR

# And login via ssh
ssh -i MyKeyPair.pem ec2-user@$IPADDR