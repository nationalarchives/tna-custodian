{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "guardduty",
      "Effect": "Allow",
        "Action": [
          "guardduty:GetFindings",
          "guardduty:GetMasterAccount",
          "guardduty:ListFindings"
        ],
      "Resource": "*"
    },
    {
      "Sid": "ec2",
      "Effect": "Allow",
        "Action": [
          "ec2:Describe*"
        ],
      "Resource": "*"
    },
    {
      "Sid": "iam",
      "Effect": "Allow",
      "Action": [
        "iam:Get*",
        "iam:List*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "s3",
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": "*"
    }
  ]
}
