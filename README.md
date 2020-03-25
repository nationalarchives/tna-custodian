# tna-custodian

## USAGE

### Prerequisites
* Terraform 12.x
* Python 3.x
* AWS CLI

### Create parameters
* Create parameter /mgmt/cost_centre in SSM parameter store, e.g.```2847``
* Create parameter /mgmt/slack/webhook in SSM parameter store, e.g.
```
HSJGUEH878/XGHDUY8982/MasJ67g2IPv8tjsrg903L
```

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

### Deploy Cloud Custodian
* deploy IAM and SQS using Terraform
```
cd terraform
git clone git@github.com:nationalarchives/tdr-configurations.git
terraform workspace new intg
terraform plan
terraform apply
```
* deploy Cloud Custodian
```
cd custodian/scripts
./deploy-custodian.sh
```
