resource "aws_iam_role" "s3_delete_marked_assume_role" {
  count              = var.s3_delete_marked == true ? 1 : 0
  name               = "CustodianDeleteMarkedS3"
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "s3_delete_marked_common_policy_attach" {
  count      = var.s3_delete_marked == true ? 1 : 0
  role       = aws_iam_role.s3_delete_marked_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

resource "aws_iam_policy" "s3_delete_marked_policy" {
  count  = var.s3_delete_marked == true ? 1 : 0
  name   = "${upper(var.project)}CustodianDeleteMarkedS3${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/custom/s3-delete-marked/s3_delete_marked_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "s3_delete_marked_policy_attach" {
  count      = var.s3_delete_marked == true ? 1 : 0
  role       = aws_iam_role.s3_delete_marked_assume_role.*.name[0]
  policy_arn = aws_iam_policy.s3_delete_marked_policy.*.arn[0]
}
