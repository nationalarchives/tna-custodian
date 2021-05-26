#!/bin/bash
#usage: ./tdr-mgmt-deploy.sh

ENVIRONMENT="mgmt"
OWNER="TDR"
TO_ADDRESS="tdr-secops@nationalarchives.gov.uk"
#only retrieve the private subnets
SUBNETS=$(aws ec2 describe-subnets --filters Name=tag:Name,Values=*-private-* | jq '.Subnets[].SubnetId')
SECURITY_GROUPS=$(aws ec2 describe-security-groups | jq '.SecurityGroups[].GroupId')

echo "Cloud Custodian will now deploy to $OWNER $ENVIRONMENT. You have 5 seconds to Ctrl-C"
sleep 5

../custodian/scripts/deploy-custodian.sh "$ENVIRONMENT" "$OWNER" "$TO_ADDRESS" "$SUBNETS" "$SECURITY_GROUPS"
