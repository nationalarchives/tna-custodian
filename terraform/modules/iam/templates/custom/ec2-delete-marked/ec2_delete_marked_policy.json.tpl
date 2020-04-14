{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteNetworkInterface",
        "ec2:DeleteVolume",
        "ec2:Describe*",
        "ec2:DetachNetworkInterface",
        "ec2:DisassociateAddress",
        "ec2:ReleaseAddress",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": "*"
    }
  ]
}