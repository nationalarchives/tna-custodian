#!/bin/bash
#usage: ./deploy-custodian.sh

COST_CENTRE=$(aws ssm get-parameter --name /mgmt/cost_centre | jq '.Parameter.Value' | tr -d '"')
SLACK_WEBHOOK=$(aws ssm get-parameter --name /mgmt/slack/webhook-test | jq '.Parameter.Value' | tr -d '"')
HOSTED_ZONE=$(aws route53 list-hosted-zones --max-items 1 | jq '.HostedZones[0].Name' | tr -d '"')
CUSTODIAN_REGION="eu-west-2"
SES_REGION="eu-west-1"
OWNER="TDR"
ENVIRONMENT="mgmt"

echo "Cloud Custodian will now deploy. You have 5 seconds to Ctrl-C"
sleep 5

echo "Configuring mailer"
python build-mailer-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --from_address custodian@"$HOSTED_ZONE" --owner "$OWNER" --region "$SES_REGION"
c7n-mailer -c deploy.yml --update-lambda

echo "Deploying IAM MFA-Warn policy"
python build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../policies/iam/mfa-warn.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK"
custodian run -s logs --region="$CUSTODIAN_REGION" --profile=management deploy.yml
