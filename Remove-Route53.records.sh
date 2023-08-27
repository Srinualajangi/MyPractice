#!/bin/bash

NAMES=("redis" "mysql" "rabbitmq" "user" "cart" "shipping" "payment" "dispatch")
DOMAIN_NAME="glitztechs.com"
HOSTED_ZONE_ID="Z0205715205SMVXZPYKDQ"

for i in "${NAMES[@]}"
do
    aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch '{
        "Changes": [{
            "Action": "DELETE",
            "ResourceRecordSet": {
                "Name": "'$i.$DOMAIN_NAME'",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": []
            }
        }]
    }'
    echo "Removed Route 53 record for $i.$DOMAIN_NAME"
done
