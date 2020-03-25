#!/bin/bash
#usage: ./deploy-custodian.sh

COST_CENTRE=$(aws ssm get-parameter --name /mgmt/cost_centre | jq '.Parameter.Value' | tr -d '"')
SLACK_WEBHOOK=$(aws ssm get-parameter --name /mgmt/slack/webhook | jq '.Parameter.Value' | tr -d '"')

echo "Cloud Custodian will now deploy. You have 5 seconds to Ctrl-C"
sleep 5

echo "Configuring mailer"

python build-mailer-yml.py --cost_centre "$COST_CENTRE" --environment mgmt --from_address cloud-custodian@tdr-management.nationalarchives.gov.uk --owner TDR

c7n-mailer -c deploy.yml --update-lambda

echo "Deploying IAM MFA-Warn policy"
rm -f deploy.yml
sed "s|{slack_webhook}|$SLACK_WEBHOOK|g" ../policies/iam/mfa-warn.yml > deploy.yml
custodian run -s logs --region=eu-west-2 --profile=management deploy.yml
