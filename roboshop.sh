#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-052879cc69a4a54b5"
INSTANCE_TYPE="t3.micro"
ZONE_ID="Z09617511B5QP2P5E3AO"
DEMO_DOMAIN="madhan66.store"

for instance in "$@"; do
  echo "🔄 Launching instance for: $instance..."

  InstanceId=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INSTANCE_TYPE \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text 2>/dev/null)

  if [[ -z "$InstanceId" ]]; then
    echo "❌ Failed to launch instance for: $instance"
    exit 1
  fi

  echo "✅ Instance launched: $InstanceId"
  sleep 5

  if [[ "$instance" == "frontend" ]]; then
    IP=$(aws ec2 describe-instances \
      --instance-ids "$InstanceId" \
      --query 'Reservations[0].Instances[0].PublicIpAddress' \
      --output text)
  else
    IP=$(aws ec2 describe-instances \
      --instance-ids "$InstanceId" \
      --query 'Reservations[0].Instances[0].PrivateIpAddress' \
      --output text)
  fi

  echo "$instance: $IP"

  echo "🌐 Creating DNS record for $instance.$DEMO_DOMAIN -> $IP"

  aws route53 change-resource-record-sets \
    --hosted-zone-id "$ZONE_ID" \
    --change-batch '{
      "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'"$instance.$DEMO_DOMAIN"'",
          "Type": "A",
          "TTL": 300,
          "ResourceRecords": [{"Value": "'"$IP"'"}]
        }
      }]
    }' >/dev/null

  echo "✅ DNS record created: $instance.$DEMO_DOMAIN"
done
