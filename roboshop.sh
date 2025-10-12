#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-052879cc69a4a54b5"  # Replace with your actual security group ID
INSTANCE_TYPE="t3.micro"

for instance in "$@"; do
  echo "🔄 Launching instance for: $instance..."

  # Run instance
  InstanceId=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INSTANCE_TYPE \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text 2>&1)

  echo "✅ Instance launched: $InstanceId"
  sleep 5  # Wait a bit to allow the instance to initialize

  # Get IP address
  if [[ "$instance" == "frontend" ]]; then
    IP=$(aws ec2 describe-instances \
      --instance-ids $InstanceId \
      --query 'Reservations[0].Instances[0].PublicIpAddress' \
      --output text)
  else
    IP=$(aws ec2 describe-instances \
      --instance-ids $InstanceId \
      --query 'Reservations[0].Instances[0].PrivateIpAddress' \
      --output text)
  fi

  echo "$instance: $IP"
done
