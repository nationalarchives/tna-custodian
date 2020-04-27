resource "aws_iam_role" "s3_remove_public_acl_assume_role" {
  count              = var.s3_remove_public_acl == true ? 1 : 0
  name               = "CustodianS3RemovePublicAcl"
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "s3_remove_public_acl_common_policy_attach" {
  count      = var.s3_remove_public_acl == true ? 1 : 0
  role       = aws_iam_role.s3_remove_public_acl_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

resource "aws_iam_policy" "s3_remove_public_acl_policy" {
  count  = var.s3_remove_public_acl == true ? 1 : 0
  name   = "${upper(var.project)}CustodianS3RemovePublicAcl${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/custom/s3_remove_public_acl_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "s3_remove_public_acl_policy_attach" {
  count      = var.s3_remove_public_acl == true ? 1 : 0
  role       = aws_iam_role.s3_remove_public_acl_assume_role.*.name[0]
  policy_arn = aws_iam_policy.s3_remove_public_acl_policy.*.arn[0]
}
