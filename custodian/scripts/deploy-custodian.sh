#!/bin/bash
OWNER=$1
ENVIRONMENT=$2
TO_ADDRESS=$3
SQS_ACCOUNT=$4

COST_CENTRE=$(aws ssm get-parameter --name /mgmt/cost_centre | jq '.Parameter.Value' | tr -d '"')
SLACK_WEBHOOK=$(aws ssm get-parameter --with-decryption --name /$ENVIRONMENT/release/slack/webhook | jq '.Parameter.Value' | tr -d '"')
HOSTED_ZONE=$(aws route53 list-hosted-zones --max-items 1 | jq '.HostedZones[0].Name' | tr -d '"' | sed 's/.$//')
CUSTODIAN_REGION_1="eu-west-2"
CUSTODIAN_REGION_2="eu-west-1"
SES_REGION="eu-west-2"

echo "Configuring mailer"
python ../custodian/scripts/build-mailer-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --from_address custodian@"$HOSTED_ZONE" --owner "$OWNER" --region "$SES_REGION"
c7n-mailer -c deploy.yml -t ../custodian/templates --update-lambda

echo "Configuring Cloud Custodian to alert to SQS queue in Account $ENVIRONMENT"

echo "Deploying IAM Access-Key-Warn policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/access-key-warn.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying IAM Access-Key-Disable policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/access-key-disable.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying IAM Access-Key-Delete policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/access-key-delete.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying IAM MFA-Warn policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/iam/mfa-warn.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying EC2 Security Group ingress policy to $CUSTODIAN_REGION_1"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/sg-ingress.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying EC2 Security Group ingress policy to $CUSTODIAN_REGION_2"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/sg-ingress.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_2" deploy.yml

echo "Deploying CloudTrail detect root user policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/cloudtrail/detect-root-logins.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying mark unencrypted EC2 instance policy to $CUSTODIAN_REGION_1"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-mark-unencrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying mark unencrypted EC2 instance policy to $CUSTODIAN_REGION_2"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-mark-unencrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_2" deploy.yml

echo "Deploying unmark encrypted EC2 instance policy to $CUSTODIAN_REGION_1"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-unmark-encrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying unmark encrypted EC2 instance policy to $CUSTODIAN_REGION_2"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-unmark-encrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_2" deploy.yml

echo "Deploying delete marked EC2 instance policy to $CUSTODIAN_REGION_1"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-delete-marked.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying delete marked EC2 instance policy to $CUSTODIAN_REGION_2"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ec2/ec2-delete-marked.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_2" deploy.yml

echo "Deploying mark unencrypted S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-mark-unencrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying check missing SSL S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-check-missing-ssl.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying unmark encrypted S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-unmark-encrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying delete marked unencrypted S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-delete-marked-unencrypted.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying Guard Duty notify policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/guardduty/guard-duty-notify.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying S3 remove public acl policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-remove-public-acl.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying mark public S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-mark-public-policy.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying unmark public S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-unmark-public-policy.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying delete marked public S3 bucket policy"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-delete-marked-public-policy.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying notify no VPC flow logs policy to $CUSTODIAN_REGION_1"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/vpc/vpc-notify-no-flow-logs.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying notify no VPC flow logs policy to $CUSTODIAN_REGION_2"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/vpc/vpc-notify-no-flow-logs.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_2" deploy.yml

echo "Deploying S3 check public block"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/s3/s3-check-public-block-policy.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml

echo "Deploying ECR check scan on push block"
python ../custodian/scripts/build-policy-yml.py --cost_centre "$COST_CENTRE" --environment "$ENVIRONMENT" --filepath "../custodian/policies/ecr/ecr-scan-on-push.yml" --owner "$OWNER" --slack_webhook "$SLACK_WEBHOOK" --to_address "$TO_ADDRESS" --sqs_region "$SES_REGION" --sqs_account "$SQS_ACCOUNT"
custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml
