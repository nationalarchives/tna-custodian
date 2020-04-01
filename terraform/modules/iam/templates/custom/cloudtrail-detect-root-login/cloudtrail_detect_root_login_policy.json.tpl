{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "events:DescribeEventSource",
        "events:DescribeRule",
        "events:EnableRule",
        "events:PutEvents",
        "events:PutPermission",
        "events:PutRule",
        "events:PutTargets",
        "events:TestEventPattern"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudtrail:DescribeTrails",
        "cloudtrail:GetTrail",
        "cloudtrail:LookupEvents"
      ],
      "Resource": "*"
    }
  ]
}
