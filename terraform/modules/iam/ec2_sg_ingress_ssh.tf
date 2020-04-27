resource "aws_iam_role_policy_attachment" "ec2_sg_ingress_lambda_common_policy_attach" {
  count      = var.ec2_sg_ingress_ssh == true ? 1 : 0
  role       = aws_iam_role.ec2_sg_ingress_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

resource "aws_iam_role" "ec2_sg_ingress_assume_role" {
  count              = var.ec2_sg_ingress_ssh == true ? 1 : 0
  name               = "CustodianEc2SgIngress"
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_policy" "ec2_sg_ingress_policy" {
  count  = var.ec2_sg_ingress_ssh == true ? 1 : 0
  name   = "${upper(var.project)}CustodianEc2SgIngress${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/custom/ec2_sg_ingress_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "ec2_sg_ingress_policy_attach" {
  count      = var.ec2_sg_ingress_ssh == true ? 1 : 0
  role       = aws_iam_role.ec2_sg_ingress_assume_role.*.name[0]
  policy_arn = aws_iam_policy.ec2_sg_ingress_policy.*.arn[0]
}
