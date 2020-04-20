#!/bin/bash
OWNER=$1
ENVIRONMENT=$2
TO_ADDRESS=$3
COST_CENTRE=$(aws ssm get-parameter --name /mgmt/cost_centre | jq '.Parameter.Value' | tr -d '"')
SLACK_WEBHOOK=$(aws ssm get-parameter --name /mgmt/slack/webhook | jq '.Parameter.Value' | tr -d '"')
HOSTED_ZONE=$(aws route53 list-hosted-zones --max-items 1 | jq '.HostedZones[0].Name' | tr -d '"' | sed 's/.$//')
CUSTODIAN_REGION_1="eu-west-2"
CUSTODIAN_REGION_2="eu-west-1"
SES_REGION="eu-west-2"
SQS_ACCOUNT=$(aws sts get-caller-identity | jq '.Account' | tr -d '"')

echo "Configuring mailer"
python ../custodian/scripts/build-mailer-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --from_address custodian@"$HOSTED_ZONE" --owner "$OWNER" --region "$SES_REGION"
c7n-mailer -c deploy.yml --update-lambda

echo "Configuring Cloud Custodian to alert to SQS queue in Account $SQS_ACCOUNT"

echo "Deploying IAM Access-Key-Warn policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/access-key-warn.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying IAM Access-Key-Disable policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/access-key-disable.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying IAM Access-Key-Delete policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/access-key-delete.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying IAM MFA-Warn policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/mfa-warn.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying EC2 Security Group ingress policy to $CUSTODIAN_REGION_1"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/sg-ingress.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying EC2 Security Group ingress policy to $CUSTODIAN_REGION_2"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/sg-ingress.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_2" deploy.yml

echo "Deploying CloudTrail detect root user policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/cloudtrail/detect-root-logins.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying mark unencrypted EC2 instance policy to $CUSTODIAN_REGION_1"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-mark-unencrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying mark unencrypted EC2 instance policy to $CUSTODIAN_REGION_2"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-mark-unencrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_2" deploy.yml

echo "Deploying unmark encrypted EC2 instance policy to $CUSTODIAN_REGION_1"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-unmark-encrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying unmark encrypted EC2 instance policy to $CUSTODIAN_REGION_2"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-unmark-encrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_2" deploy.yml

echo "Deploying delete marked EC2 instance policy to $CUSTODIAN_REGION_1"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-delete-marked.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying delete marked EC2 instance policy to $CUSTODIAN_REGION_2"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-delete-marked.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_2" deploy.yml

echo "Deploying mark unencrypted S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-mark-unencrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying unmark encrypted S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-unmark-encrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying delete marked S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-delete-marked.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml
