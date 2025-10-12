#!/bin/bash
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-052879cc69a4a54b5" # Replace with your security group ID

for instance in $@; 
do
  InstanceId=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-052879cc69a4a54b5 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Test}]' --query 'Instances[0].[InstanceId,PrivateIpAddress]' --output text)

   # Get private ip
   if [ $instance != "frontend" ]; then
     IP=$(aws ec2 describe-instances --instance-ids i-0cd05fcf4f2a124ef --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
   else
     IP=$(aws ec2 describe-instances --instance-ids i-0cd05fcf4f2a124ef --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
   fi

   echo "$instance: $IP"
done