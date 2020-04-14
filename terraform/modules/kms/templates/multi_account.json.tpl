{
  "Version": "2012-10-17",
  "Id": "custodian-sqs-encryption",
  "Statement": [
  {
    "Sid": "Enable IAM User Permissions across multiple accounts",
    "Effect": "Allow",
    "Principal": {
      "AWS": [
        "arn:aws:iam::${account_id}:root",
        "arn:aws:iam::${external_account_1}:root",
        "arn:aws:iam::${external_account_2}:root",
        "arn:aws:iam::${external_account_3}:root"
      ]
    },
    "Action": "kms:*",
    "Resource": "*"
    }
  ]
}