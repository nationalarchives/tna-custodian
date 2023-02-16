resource "aws_iam_role" "s3_mark_missing_ssl_assume_role" {
  count              = var.s3_mark_missing_ssl == true ? 1 : 0
  name               = "CustodianMarkMissingSSLPolicyS3"
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "s3_mark_missing_ssl_common_policy_attach" {
  count      = var.s3_mark_missing_ssl == true ? 1 : 0
  role       = aws_iam_role.s3_mark_missing_ssl_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

resource "aws_iam_policy" "s3_mark_missing_ssl_policy" {
  count  = var.s3_mark_missing_ssl == true ? 1 : 0
  name   = "${upper(var.project)}CustodianMarkMissingSSLS3${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/custom/s3_mark_missing_ssl_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "s3_mark_missing_ssl_policy_attach" {
  count      = var.s3_mark_missing_ssl == true ? 1 : 0
  role       = aws_iam_role.s3_mark_missing_ssl_assume_role.*.name[0]
  policy_arn = aws_iam_policy.s3_mark_missing_ssl_policy.*.arn[0]
}
