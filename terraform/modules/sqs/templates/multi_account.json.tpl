{
  "Version": "2012-10-17",
  "Id": "SQSExternalPolicy",
  "Statement": [
    {
      "Sid": "externalaccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${external_account_1}:root",
          "arn:aws:iam::${external_account_2}:root",
          "arn:aws:iam::${external_account_3}:root"
        ]
      },
      "Action": "SQS:SendMessage",
      "Resource": "${queue_arn}"
    }
  ]
}
