#!/bin/bash
#usage: ./deploy-custodian.sh

ACCOUNT_ID=$(aws sts get-caller-identity | jq '.Account' | tr -d '"')
SLACK_WEBHOOK=$(aws ssm get-parameter --name /mgmt/slack/webhook | jq '.Parameter.Value' | tr -d '"')

echo "Cloud Custodian will now deploy. You have 5 seconds to Ctrl-C"
sleep 5

echo "Configuring mailer"
rm -f deploy.yml
sed "s|{account_id}|${ACCOUNT_ID}|g" ../mailer/mailer.yml > deploy.yml
c7n-mailer -c deploy.yml --update-lambda

echo "Deploying IAM MFA-Warn policy"
rm -f deploy.yml
sed "s|{slack_webhook}|$SLACK_WEBHOOK|g" ../policies/iam/mfa-warn.yml > deploy.yml
custodian run -s logs --region=eu-west-2 --profile=management deploy.yml
