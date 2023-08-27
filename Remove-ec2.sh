#!/bin/bash

NAMES=("redis" "mysql" "rabbitmq" "user" "cart" "shipping" "payment" "dispatch")

for i in "${NAMES[@]}"
do
    INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$i" --query "Reservations[0].Instances[0].InstanceId" --output text)
    
    if [ -n "$INSTANCE_ID" ]; then
        aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"
        echo "Terminated $i instance: $INSTANCE_ID"
    else
        echo "$i instance not found"
    fi
done
