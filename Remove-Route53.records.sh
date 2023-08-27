#!/bin/bash

NAMES=("redis" "mysql" "rabbitmq" "user" "cart" "shipping" "payment" "dispatch")
DOMAIN_NAME="glitztechs.com"
HOSTED_ZONE_ID="Z0205715205SMVXZPYKDQ"

for i in "${NAMES[@]}"
do
    # Describe the record and get its details
    RECORD_INFO=$(aws route53 list-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --query "ResourceRecordSets[?Name=='$i.$DOMAIN_NAME.']" --output json)
    
    # Check if the record exists
    if [ -n "$RECORD_INFO" ]; then
        # Extract the record details
        RECORD_TYPE=$(echo "$RECORD_INFO" | jq -r '.[0].Type')
        TTL=$(echo "$RECORD_INFO" | jq -r '.[0].TTL')
        RESOURCE_RECORDS=$(echo "$RECORD_INFO" | jq -c '.[0].ResourceRecords')

        # Delete the record
        aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch '{
            "Changes": [{
                "Action": "DELETE",
                "ResourceRecordSet": {
                    "Name": "'$i.$DOMAIN_NAME'",
                    "Type": "'$RECORD_TYPE'",
                    "TTL": '$TTL',
                    "ResourceRecords": '$RESOURCE_RECORDS'
                }
            }]
        }'
        echo "Removed Route 53 record for $i.$DOMAIN_NAME"
    else
        echo "Route 53 record for $i.$DOMAIN_NAME not found"
    fi
done
