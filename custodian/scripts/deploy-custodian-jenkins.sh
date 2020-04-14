#!/bin/bash
OWNER=$1
ENVIRONMENT=$2
TO_ADDRESS=$3
SQS_ACCOUNT=$4
ASSUME_ROLE=$5
COST_CENTRE=$(aws ssm get-parameter --name /mgmt/cost_centre | jq '.Parameter.Value' | tr -d '"')
SLACK_WEBHOOK=$(aws ssm get-parameter --name /mgmt/slack/webhook | jq '.Parameter.Value' | tr -d '"')
CUSTODIAN_REGION="eu-west-2"
SES_REGION="eu-west-2"

echo "Setting up Cloud Custodian to alert to SQS queue in Account $SQS_ACCOUNT"

echo "Deploying IAM Access-Key-Warn policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/access-key-warn.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying IAM Access-Key-Disable policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/access-key-disable.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying IAM Access-Key-Delete policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/access-key-delete.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying IAM MFA-Warn policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/mfa-warn.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying EC2 Security Group ingress policy to $CUSTODIAN_REGION"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/sg-ingress.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying EC2 Security Group ingress policy to $SES_REGION"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/sg-ingress.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$SES_REGION" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying CloudTrail detect root user policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/cloudtrail/detect-root-logins.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION" --assume="$ASSUME_ROLE" deploy.yml
