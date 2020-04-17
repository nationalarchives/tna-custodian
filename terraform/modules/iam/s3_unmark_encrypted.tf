resource "aws_iam_role" "s3_unmark_encrypted_assume_role" {
  count              = var.s3_unmark_encrypted == true ? 1 : 0
  name               = "CustodianUnmarkEncryptedS3"
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "s3_unmark_encrypted_common_policy_attach" {
  count      = var.s3_unmark_encrypted == true ? 1 : 0
  role       = aws_iam_role.s3_unmark_encrypted_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

resource "aws_iam_policy" "s3_unmark_encrypted_policy" {
  count  = var.s3_unmark_encrypted == true ? 1 : 0
  name   = "${upper(var.project)}CustodianUnmarkEncryptedS3${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/custom/s3-unmark-encrypted/s3_unmark_encrypted_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "s3_unmark_encrypted_policy_attach" {
  count      = var.s3_unmark_encrypted == true ? 1 : 0
  role       = aws_iam_role.s3_unmark_encrypted_assume_role.*.name[0]
  policy_arn = aws_iam_policy.s3_unmark_encrypted_policy.*.arn[0]
}
