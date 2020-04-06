#!/bin/bash
OWNER=$1
ENVIRONMENT=$2
TO_ADDRESS=$3
COST_CENTRE=$(aws ssm get-parameter --name /mgmt/cost_centre | jq '.Parameter.Value' | tr -d '"')
SLACK_WEBHOOK=$(aws ssm get-parameter --name /mgmt/slack/webhook | jq '.Parameter.Value' | tr -d '"')
HOSTED_ZONE=$(aws route53 list-hosted-zones --max-items 1 | jq '.HostedZones[0].Name' | tr -d '"' | sed 's/.$//')
CUSTODIAN_REGION="eu-west-2"
SES_REGION="eu-west-2"

echo "Configuring mailer"
python ../custodian/scripts/build-mailer-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --from_address custodian@"$HOSTED_ZONE" --owner "$OWNER" --region "$SES_REGION"
c7n-mailer -c deploy.yml --update-lambda

echo "Deploying IAM Access-Key-Warn policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/access-key-warn.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION" deploy.yml

echo "Deploying IAM MFA-Warn policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/mfa-warn.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION" deploy.yml

echo "Deploying EC2 Security Group ingress policy to $CUSTODIAN_REGION"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/sg-ingress.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION" deploy.yml

echo "Deploying EC2 Security Group ingress policy to $SES_REGION"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/sg-ingress.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$SES_REGION" deploy.yml

echo "Deploying CloudTrail detect root user policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/cloudtrail/detect-root-logins.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION" deploy.yml
