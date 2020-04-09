resource "aws_iam_role" "ec2_unmark_encrypted_assume_role" {
  count              = var.ec2_unmark_encrypted == true ? 1 : 0
  name               = "CustodianUnmarkEncryptedEC2"
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "ec2_unmark_encrypted_common_policy_attach" {
  count      = var.ec2_unmark_encrypted == true ? 1 : 0
  role       = aws_iam_role.ec2_unmark_encrypted_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

resource "aws_iam_policy" "ec2_unmark_encrypted_policy" {
  count  = var.ec2_unmark_encrypted == true ? 1 : 0
  name   = "${upper(var.project)}CustodianUnmarkEncryptedEC2${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/custom/ec2-unmark-encrypted/ec2_unmark_encrypted_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "ec2_unmark_encrypted_policy_attach" {
  count      = var.ec2_unmark_encrypted == true ? 1 : 0
  role       = aws_iam_role.ec2_unmark_encrypted_assume_role.*.name[0]
  policy_arn = aws_iam_policy.ec2_unmark_encrypted_policy.*.arn[0]
}
