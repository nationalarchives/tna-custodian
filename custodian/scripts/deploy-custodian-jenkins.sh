#!/bin/bash
OWNER=$1
ENVIRONMENT=$2
TO_ADDRESS=$3
SQS_ACCOUNT=$4
ASSUME_ROLE=$5
COST_CENTRE=$(aws ssm get-parameter --name /mgmt/cost_centre | jq '.Parameter.Value' | tr -d '"')
SLACK_WEBHOOK=$(aws ssm get-parameter --name /mgmt/slack/webhook | jq '.Parameter.Value' | tr -d '"')
CUSTODIAN_REGION_1="eu-west-2"
CUSTODIAN_REGION_2="eu-west-1"
SES_REGION="eu-west-2"

echo "Setting up Cloud Custodian to alert to SQS queue in Account $SQS_ACCOUNT"

echo "Deploying IAM Access-Key-Warn policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/access-key-warn.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying IAM Access-Key-Disable policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/access-key-disable.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying IAM Access-Key-Delete policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/access-key-delete.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying IAM MFA-Warn policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/mfa-warn.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying EC2 Security Group ingress policy to $CUSTODIAN_REGION_1"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/sg-ingress.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying EC2 Security Group ingress policy to $CUSTODIAN_REGION_2"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/sg-ingress.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$SES_REGION" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying CloudTrail detect root user policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/cloudtrail/detect-root-logins.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying CloudTrail mark unencrypted EC2 instance policy to $CUSTODIAN_REGION_1"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-mark-unencrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying CloudTrail mark unencrypted EC2 instance policy to $CUSTODIAN_REGION_2"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-mark-unencrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_2" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying CloudTrail unmark encrypted EC2 instance policy to $CUSTODIAN_REGION_1"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-unmark-encrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying CloudTrail unmark encrypted EC2 instance policy to $CUSTODIAN_REGION_2"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-unmark-encrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_2" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying CloudTrail delete marked EC2 instance policy to $CUSTODIAN_REGION_1"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-delete-marked.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying CloudTrail delete marked EC2 instance policy to $CUSTODIAN_REGION_2"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-delete-marked.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_2" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying mark unencrypted S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-mark-unencrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying unmark encrypted S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-unmark-encrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying delete marked unencrypted S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-delete-marked-unencrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying Guard Duty notify policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/guardduty/guard-duty-notify.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying S3 remove public acl policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-remove-public-acl.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying mark public S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-mark-public-policy.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying unmark public S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-unmark-public-policy.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml

echo "Deploying delete marked public S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-delete-marked-public-policy.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" --assume="$ASSUME_ROLE" deploy.yml