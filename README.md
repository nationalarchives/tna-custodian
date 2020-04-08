# tna-custodian

## ALERTS AND REMEDIATIONS
* This implementation of Cloud Custodian includes the following alerts and automated remediations:

| AWS SERVICE | RULE NAME            | CONDITION                                                   | REMEDIATION                |
| ----------- | -------------------- | ----------------------------------------------------------- | -------------------------- |
| CloudTrail  | Detect-root-login    | Root user logs in to AWS Console                            | None                       | 
| EC2         | SG-ingress           | Security group with inbound from any, except HTTP and HTTPS | Remove security group rule | 
| IAM         | Access-key-warn      | Access keys older than 80 days                              | None                       |
| IAM         | MFA-warn             | Console user without MFA                                    | None                       |

## USAGE

### Prerequisites
* Terraform 12.x
* Python 3.x
* AWS CLI
* Boto3

### Create parameters
* Create parameter /mgmt/cost_centre in SSM parameter store, e.g.```2847```
* Create parameter /mgmt/slack/webhook in SSM parameter store, e.g.```HSJGUEH878/XGHDUY8982/MasJ67g2IPv8tjsrg903L```

### Install Cloud Custodian
* use virtual environment
```
python3 -m venv custodian
source custodian/bin/activate
```
* install Cloud Custodian
```
(custodian) pip install c7n
```

### Install Custodian Mailer
* ensure you are still within the Python virtual environment
```
(custodian) pip install c7n-mailer
``` 

### Deploy Cloud Custodian in TDR management account
* deploy from laptop
* deploy IAM and SQS using Terraform
```
cd terraform
git clone git@github.com:nationalarchives/tdr-configurations.git
terraform workspace new mgmt
terraform plan
terraform apply
```
* deploy Cloud Custodian to TDR management account
```
cd custodian/accounts
./tdr-mgmt-deploy.sh
```

### Deploy Cloud Custodian in other TDR environments
* deploy using Jenkins
* use TDR Custodian Deploy pipeline

### Deploy in other TNA accounts
* set terraform variable for project, e.g. ```project = "tna"```
* set terraform variable ```assume_tdr_role = false```
* copy accounts/tdr-mgmt-deploy.sh, rename file and update variables as appropriate
* deploy terraform and then run the shell script to deploy Cloud Custodian 

### Testing new policies
* New Cloud Custodian policies should be tested in a safe way
* Amend custodian/scripts/deploy-custodian.sh
* Use ```custodian run --dryrun``` and check CloudWatch logs for findings
* For region specific policies, test in the eu-west-1 region
* For global policies, test in another AWS account
* Use the parameter /mgmt/slack/webhook-test for a private Slack Channel
* Update the custodian run command with a test email address

### Destroy Cloud Custodian
* destroy Cloud Custodian resources
```
cd custodian/scripts
python destroy-custodian.py --dry_run
python destroy-custodian.py
```
* optionally an AWS CLI profile may be set
```
python destroy-custodian.py --profile management
```
* destroy Terraform resources
```
terraform workspace select mgmt
terraform destroy
yes
```

### LINKS
* [Cloud Custodian documentation](https://cloudcustodian.io)
* [Cloud Custodian GitHub repository](https://github.com/cloud-custodian)
