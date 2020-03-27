#!/bin/bash
#usage: ./tdr-mgmt-deploy.sh

ENVIRONMENT="mgmt"
OWNER="TDR"
TO_ADDRESS="tdr-secops@nationalarchives.gov.uk"

echo "Cloud Custodian will now deploy to $OWNER $ENVIRONMENT. You have 5 seconds to Ctrl-C"
sleep 5

../custodian/scripts/deploy-custodian.sh "$ENVIRONMENT" "$OWNER" "$TO_ADDRESS"
