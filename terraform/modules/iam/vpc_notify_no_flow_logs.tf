resource "aws_iam_role" "ec2_mark_no_flow_logs_assume_role" {
  count              = var.ec2_mark_no_flow_logs == true ? 1 : 0
  name               = "CustodianMarkNoVpcFlowLogs"
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "ec2_mark_no_flow_logs_common_policy_attach" {
  count      = var.ec2_mark_no_flow_logs == true ? 1 : 0
  role       = aws_iam_role.ec2_mark_no_flow_logs_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

resource "aws_iam_policy" "ec2_mark_no_flow_logs_policy" {
  count  = var.ec2_mark_no_flow_logs == true ? 1 : 0
  name   = "${upper(var.project)}CustodianMarkNoVpcFlowLogs${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/custom/vpc_notify_no_flow_logs_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "ec2_mark_no_flow_logs_policy_attach" {
  count      = var.ec2_mark_no_flow_logs == true ? 1 : 0
  role       = aws_iam_role.ec2_mark_no_flow_logs_assume_role.*.name[0]
  policy_arn = aws_iam_policy.ec2_mark_no_flow_logs_policy.*.arn[0]
}
