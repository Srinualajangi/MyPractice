#!/bin/bash

NAMES=("redis" "mysql" "rabbitmq" "user" "cart" "shipping" "payment" "dispatch")
INSTANCE_TYPE=""
DOMAIN_NAME=glitztechs.com
AMI_ID=ami-03265a0778a880afb
SECURITY_GROUP_ID=sg-05a39fb39312bc6d3

for i in "${NAMES[@]}"
do 
    if [[ $i = "mysql" ]]
        then INSTANCE_TYPE="t3.medium" 
    else 
        INSTANCE_TYPE="t2.micro"
    fi
    echo "Creating $i Instance "
    IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI_ID  --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "created $i instance: $IP_ADDRESS

    aws route53 change-resource-record-sets --hosted-zone-id Z0205715205SMVXZPYKDQ --change-batch '
    {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": "'$i.$DOMAIN_NAME'",
                            "Type": "A",
                            "TTL": 300,
                            "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                        }}]
    }
    '
done