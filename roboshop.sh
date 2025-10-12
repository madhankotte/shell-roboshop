#!/bin/bash
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-052879cc69a4a54b5" # Replace with your security group ID

for instance in $@; 
do
  InstanceId=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Test}]' --query 'Instances[0].[InstanceId,PrivateIpAddress]' --output text)

   # Get private ip
   if [ $instance != "frontend" ]; then
     IP=$(aws ec2 describe-instances --instance-ids $InstanceId --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    else
     IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$instance" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
   fi

   echo "$instance: $IP"
done