# tna-custodian

## ALERTS AND REMEDIATIONS
* This implementation of Cloud Custodian includes the following alerts and automated remediations:

| AWS SERVICE | RULE NAME                              | CONDITION                                                                                                 | REMEDIATION                 |
| ----------- |----------------------------------------|-----------------------------------------------------------------------------------------------------------|-----------------------------|
| CloudTrail  | Detect-root-login                      | Root user logs in to AWS Console                                                                          | None                        |
| CloudTrail  | iam-admin-role-assumption              | The IAM_Admin_Role is assumed in any enabled region                                                       | None                        |
| DynamoDb    | Reference Counter Table specific rules | Set of checks specific to the reference counter table. See [README][reference-counter-readme] for details | Not Applicable              |
| EC2         | SG-ingress                             | Security group with inbound from any, except HTTP and HTTPS (ports 80 and 443)                            | Remove security group rule  | 
| EC2         | Mark-unencrypted                       | EC2 virtual machine not encrypted                                                                         | Mark for deletion in 3 days | 
| EC2         | Unmark-encrypted                       | Previously marked virtual machine now encrypted                                                           | Remove mark                 | 
| EC2         | Delete-marked                          | Marked virtual machine date condition met                                                                 | Terminate instance          | 
| ECR         | Vulnerability-Scanning-Enabled         | Repository without scan-on-push enabled                                                                   | Enable scan-on-push         | 
| GuardDuty   | Notify                                 | Guard Duty finding with medium or high priority for EC2 Instances only                                    | None                        | 
| IAM         | Access-key-warn                        | Active access keys older than 80 days                                                                     | None                        |
| IAM         | Access-key-disable                     | Active access keys older than 85 days                                                                     | Disable keys                |
| IAM         | Access-key-delete                      | Access keys older than 90 days                                                                            | Delete keys                 |
| IAM         | MFA-warn                               | Console user without MFA                                                                                  | None                        |
| S3          | Mark-unencrypted                       | S3 bucket not encrypted                                                                                   | Mark for deletion in 3 days | 
| S3          | Unmark-encrypted                       | Previously marked S3 bucket now encrypted                                                                 | Remove mark                 | 
| S3          | Delete-marked-unencrypted              | Marked S3 bucket date condition met                                                                       | Empty and delete bucket     |
| S3          | Check-missing-ssl-policy               | S3 bucket missing policy with statement named AllowSSLRequestsOnly                                        | Add SSL only policy         | 
| S3          | Remove-public-acls                     | Public ACLs at S3 bucket level                                                                            | Remove public ACLs          | 
| S3          | Mark-public-policy                     | S3 bucket with public policy (s3:* or s3:GetObject actions allowed by wildcard principal)                 | Mark for deletion in 3 days | 
| S3          | Unmark-public-policy                   | Previously marked S3 bucket no longer public (s3:* or s3:GetObject actions allowed by wildcard principal) | Remove mark                 | 
| S3          | Delete-marked-public-policy            | Marked S3 bucket date condition met                                                                       | Empty and delete bucket     | 
| S3          | Check-for-public-access-block          | S3 bucket without public access block                                                                     | Set public access block     |
| VPC         | Notify-no-flow-logs                    | VPC flow logs not configured and enabled                                                                  | None                        | 

[reference-counter-readme]: https://github.com/nationalarchives/tna-custodian/tree/master/custodian/policies/dynamodb/reference-counter/README.md

## USAGE

### Prerequisites
* Terraform 1.x.x
* Python 3.x
* AWS CLI
* Boto3

### Create parameters
* Create parameter /mgmt/cost_centre in SSM parameter store, e.g.```2847```
* Create parameter /mgmt/slack/webhook in SSM parameter store, e.g.```HSJGUEH878/XGHDUY8982/MasJ67g2IPv8tjsrg903L```

### Install Cloud Custodian
* Use python3 virtual environment:
```
python3 -m venv custodian
source custodian/bin/activate
```
* Install Cloud Custodian
```
(custodian) pip install c7n
```

### Install Custodian Tools/Dependencies
* Ensure you are still within the Python virtual environment
```
(custodian) pip install c7n-guardian
(custodian) pip install c7n-mailer
(custodian) pip install ruamel.yaml
``` 

## Add New Project Cloud Custodian Policy

### Adding Necessary AWS Resources for Policy in the project management account
Set up necessary IAM role and IAM policies and any other AWS resources needed for the new Custodian policy using Terraform.

Deployment of the AWS resources should be done from a development machine.

1. Clone the project:
    ```
   [location FOR project]: git clone https://github.com/nationalarchives/tna-custodian --recurse-submodules
   ```

2. Create a file terraform.tfvars in the ./terraform directory of the project, with the project management account number defined:
   ```
   tdr_account_number = "[project management account number]"
   ```
3. Initialise the Terraform

The initialisation command requires two parameters to be set
* Terraform state bucket for the project
* Terraform state lock DynamoDB table for the project

  ```
  [location of project]: terraform init -backend-config="bucket={name of the state bucket}" --backend-config="dynamodb_table={state lock table}"
  ```

4. Add the necessary Terraform scripts to create the required AWS resources for the new Cloud Custodian policy in the mgmt Terraform workspace:
   ```
   terraform workspace new mgmt     
   ```
5. Deploy the AWS resources:
   ```
   terraform plan
   terraform apply
   ```
     
### Creating the new Cloud Custodian policy
  
1. Add the policy to the correct ./custodian sub-directory, or create new sub-directory if needed.
2. In the ./scripts/deploy-custodian.sh script add deploy commands for the new policy.
3. In the ./scripts/deploy-custodian-jenkins.sh add the Jenkins deploy commands for the new policy.  

### Testing the new Cloud Custodian policy

New Cloud Custodian policies should be tested in a safe way, using the "dry run" option. 

This option runs the policy without implementing any remediation actions defined in the policy.

* For region specific policies, test in the eu-west-1 region
* For global policies, another option is to test in another AWS account
* Use the parameter /mgmt/slack/webhook-test for a private Slack Channel
* Update the custodian run command with a test email address

The steps below define the process for testing the policy in the TDR management account.

1. In the `/scripts/deploy-custodian.sh script` set the "dry run" option for the new Cloud Custodian policy, for example: 
     ```
     echo "Deploying ... etc ..."
     python ... etc ...
     custodian run --dryrun -s logs --region="$CUSTODIAN_REGION_1" deploy.yml
     ```
2. In the python virtual environment run the following command from the ./custodian/accounts directory, replacing the management_account_number placeholder: 
     ```
     (custodian) [xxxx@localhost accounts]$ ./tdr-mgmt-deploy.sh ${management_account_number}
     ```
3. Go to the relevant generated log directory (./accounts/logs/[policy name]) for the new Cloud Custodian policy and check the "resources.json" contains the correct AWS resources identified by the new policy.
4. Repeat steps as required until the new Cloud Custodian policy is correctly identifying the AWS resources

Note: Testing may highlight issues with IAM roles/policies for the Cloud Custodian policy, so adjustment of the Terraform may be required.

### Deploying new Cloud Custodian policy to TDR management account

1. Remove the "dry run" option from the `/scripts/deploy-custodian.sh script` for the new policy. For example:
     ```
     echo "Deploying ... etc ..."
     python ... etc ...
     custodian run -s logs --region="$CUSTODIAN_REGION_1" deploy.yml
     ```
     **NOTE**: without the "dry run" option the remediation actions (if any) of the new policy will be implemented for any identified AWS resources in the AWS TDR management account.
2. In the python virtual environment run the following command from the ./custodian/accounts directory, replacing the ${management_account_number} placholder:
   ```
   (custodian) [xxxx@localhost accounts]$ ./tdr-mgmt-deploy.sh ${management_account_number}
   ```
3. The new Cloud Custodian policy should be deployed to the TDR management account
4. To test the deployment without having to wait for the periodic run/trigger event for the new policy, the policy lambda can be run by using the test service on the AWS console.
5. Depending on the actions defined in the new policy, after the policy lambda has been triggered, slack and email messages should be sent, and any remediation actions performed on any AWS resources identified by the Cloud Custodian policy. 
   Note: there may be a delay in messages being sent. This is due to the lambda send the messages running periodically.

### GitHub actions Deploy Cloud
The deploy workflow runs terraform using the `terraform_apply` workflow in `dr2-github-actions` 
This repository is team specific but that workflow has been changed to be generic. We may eventually move this to a department level repository.

## Add a new team to the repository
* Add your team name to the input variable in [the apply workflow](./.github/workflows/apply.yml)
* For each environment you need to deploy to, you will need to set these secrets. There are descriptions of what each one is needed for in the [da-terraform-configurations](https://github.com/nationalarchives/da-terraform-configurations) repository. The project name must be the same as the name in the `apply.yml` choice field but in upper case.
   * {PROJECT}_{ENV_NAME}_ACCOUNT_NUMBER
   * {PROJECT}_{ENV_NAME}_CUSTODIAN_ROLE
   * {PROJECT}_{ENV_NAME}_DYNAMO_TABLE
   * {PROJECT}_{ENV_NAME}_STATE_BUCKET
   * {PROJECT}_{ENV_NAME}_TERRAFORM_EXTERNAL_ID
   * {PROJECT}_{ENV_NAME}_TERRAFORM_ROLE
* You will also need to set the following secrets which don't depend on the environment.
   * {PROJECT}_EMAIL_ADDRESS
   * {PROJECT}_MANAGEMENT_ACCOUNT
   * {PROJECT}_SLACK_WEBHOOK
   * {PROJECT}_WORKFLOW_PAT
* Set up an environment in GitHub called {project-lower-case}-{environment-lower-case} for each environment you will deploy to.
* Run the GitHub actions apply workflow. This will deploy to the chosen environment and delete the default VPCs from each region.

### Destroy Cloud Custodian
* Destroy Cloud Custodian resources
```
cd custodian/scripts
python destroy-custodian.py --dry_run
python destroy-custodian.py
```
* Optionally an AWS CLI profile may be set:
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
