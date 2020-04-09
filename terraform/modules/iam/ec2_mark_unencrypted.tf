resource "aws_iam_role" "ec2_mark_unencrypted_assume_role" {
  count              = var.ec2_mark_unencrypted == true ? 1 : 0
  name               = "CustodianMarkUnencryptedEC2"
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "ec2_mark_unencrypted_common_policy_attach" {
  count      = var.ec2_mark_unencrypted == true ? 1 : 0
  role       = aws_iam_role.ec2_mark_unencrypted_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

resource "aws_iam_policy" "ec2_mark_unencrypted_policy" {
  count  = var.ec2_mark_unencrypted == true ? 1 : 0
  name   = "${upper(var.project)}CustodianMarkUnencryptedEC2${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/custom/ec2-mark-unencrypted/ec2_mark_unencrypted_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "ec2_mark_unencrypted_policy_attach" {
  count      = var.ec2_mark_unencrypted == true ? 1 : 0
  role       = aws_iam_role.ec2_mark_unencrypted_assume_role.*.name[0]
  policy_arn = aws_iam_policy.ec2_mark_unencrypted_policy.*.arn[0]
}
