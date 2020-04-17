resource "aws_iam_role" "s3_mark_unencrypted_assume_role" {
  count              = var.s3_mark_unencrypted == true ? 1 : 0
  name               = "CustodianMarkUnencryptedS3"
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "s3_mark_unencrypted_common_policy_attach" {
  count      = var.s3_mark_unencrypted == true ? 1 : 0
  role       = aws_iam_role.s3_mark_unencrypted_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

resource "aws_iam_policy" "s3_mark_unencrypted_policy" {
  count  = var.s3_mark_unencrypted == true ? 1 : 0
  name   = "${upper(var.project)}CustodianMarkUnencryptedS3${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/custom/s3-mark-unencrypted/s3_mark_unencrypted_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "s3_mark_unencrypted_policy_attach" {
  count      = var.s3_mark_unencrypted == true ? 1 : 0
  role       = aws_iam_role.s3_mark_unencrypted_assume_role.*.name[0]
  policy_arn = aws_iam_policy.s3_mark_unencrypted_policy.*.arn[0]
}
