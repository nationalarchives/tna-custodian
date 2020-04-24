# tna-custodian

## ALERTS AND REMEDIATIONS
* This implementation of Cloud Custodian includes the following alerts and automated remediations:

| AWS SERVICE | RULE NAME                   | CONDITION                                                   | REMEDIATION                 |
| ----------- | --------------------------- | ----------------------------------------------------------- | --------------------------- |
| CloudTrail  | Detect-root-login           | Root user logs in to AWS Console                            | None                        | 
| EC2         | SG-ingress                  | Security group with inbound from any, except HTTP and HTTPS | Remove security group rule  | 
| EC2         | Mark-unencrypted            | EC2 virtual machine not encrypted                           | Mark for deletion in 3 days | 
| EC2         | Unmark-encrypted            | Previously marked virtual machine now encrypted             | Remove mark                 | 
| EC2         | Delete-marked               | Marked virtual machine date condition met                   | Terminate instance          | 
| GuardDuty   | Notify                      | Guard Duty finding with medium or high priority             | None                        | 
| IAM         | Access-key-warn             | Access keys older than 80 days                              | None                        |
| IAM         | Access-key-disable          | Access keys older than 85 days                              | Disable keys                |
| IAM         | Access-key-delete           | Access keys older than 90 days                              | Delete keys                 |
| IAM         | MFA-warn                    | Console user without MFA                                    | None                        |
| S3          | Mark-unencrypted            | S3 bucket not encrypted                                     | Mark for deletion in 3 days | 
| S3          | Unmark-encrypted            | Previously marked S3 bucket now encrypted                   | Remove mark                 | 
| S3          | Delete-marked-unencrypted   | Marked S3 bucket date condition met                         | Terminate instance          | 
| S3          | Remove-public-acls          | Public ACLs at S3 bucket level                              | Remove public ACLs          | 
| S3          | Mark-public-policy          | S3 bucket with public policy                                | Mark for deletion in 3 days | 
| S3          | Unmark-public-policy        | Previously marked S3 bucket no longer public                | Remove mark                 | 
| S3          | Delete-marked-public-policy | Marked S3 bucket date condition met                         | Terminate instance          | 
| VPC         | Notify-no-flow-logs         | VPC flow logs not configured and enabled                    | None                        | 

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
* Use virtual environment
```
python3 -m venv custodian
source custodian/bin/activate
```
* Install Cloud Custodian
```
(custodian) pip install c7n
```

### Install Custodian Tools
* Ensure you are still within the Python virtual environment
```
(custodian) pip install c7n-guardian
(custodian) pip install c7n-mailer
``` 

### Deploy Cloud Custodian in TDR management account
* Deploy from laptop
* Deploy IAM and SQS using Terraform
* create a file terraform.tfvars in the terraform folder, with e.g. ```tdr_account_number = "012345678901"```
```
cd terraform
git clone git@github.com:nationalarchives/tdr-configurations.git
terraform workspace new mgmt
terraform plan
terraform apply
```
* Deploy Cloud Custodian to TDR management account
```
cd custodian/accounts
./tdr-mgmt-deploy.sh
```

### Deploy Cloud Custodian in other TDR environments
* Deploy using Jenkins
* Use TDR Custodian Deploy pipeline

### Deploy in other TNA accounts
* Pass in the terraform backend via the command line
* Set terraform variable for project, e.g. ```project = "tna"```
* Set terraform variable ```assume_tdr_role = false```
* Copy accounts/tdr-mgmt-deploy.sh, rename file and update variables as appropriate
* Deploy terraform and then run the shell script to deploy Cloud Custodian 

### Testing new policies
* New Cloud Custodian policies should be tested in a safe way
* Amend custodian/scripts/deploy-custodian.sh
* Use ```custodian run --dryrun``` and check local logs in the accounts folder for findings
* For region specific policies, test in the eu-west-1 region
* For global policies, another option is to test in another AWS account
* Use the parameter /mgmt/slack/webhook-test for a private Slack Channel
* Update the custodian run command with a test email address

### Destroy Cloud Custodian
* Destroy Cloud Custodian resources
```
cd custodian/scripts
python destroy-custodian.py --dry_run
python destroy-custodian.py
```
* Optionally an AWS CLI profile may be set
```
python destroy-custodian.py --profile management
```
* Destroy Terraform resources
```
terraform workspace select mgmt
terraform destroy
yes
```

### LINKS
* [Cloud Custodian documentation](https://cloudcustodian.io)
* [Cloud Custodian GitHub repository](https://github.com/cloud-custodian)
