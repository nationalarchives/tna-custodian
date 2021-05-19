resource "aws_iam_role" "s3_check_public_block_assume_role" {
  count              = var.s3_check_public_block == true ? 1 : 0
  name               = "CustodianS3CheckPublicBlock"
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "s3_check_public_block_common_policy_attach" {
  count      = var.s3_check_public_block == true ? 1 : 0
  role       = aws_iam_role.s3_check_public_block_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

resource "aws_iam_role_policy_attachment" "s3_check_public_block_vpc_execution_access" {
  count      = var.s3_check_public_block == true ? 1 : 0
  role       = aws_iam_role.s3_check_public_block_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_vpc_access_execution.*.arn[0]
}

resource "aws_iam_policy" "s3_check_public_block_policy" {
  count  = var.s3_check_public_block == true ? 1 : 0
  name   = "${upper(var.project)}CustodianS3CheckPublicBlock${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/custom/s3_check_public_block_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "s3_check_public_block_policy_attach" {
  count      = var.s3_check_public_block == true ? 1 : 0
  role       = aws_iam_role.s3_check_public_block_assume_role.*.name[0]
  policy_arn = aws_iam_policy.s3_check_public_block_policy.*.arn[0]
}
