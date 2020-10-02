resource "aws_iam_role" "ecr_set_scan_on_push_role" {
  count              = var.ecr_set_scan_on_push == true ? 1 : 0
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
  name               = "CustodianECRSetScanOnPush"
}

resource "aws_iam_policy" "ecr_set_scan_on_push_policy" {
  count  = var.ecr_set_scan_on_push == true ? 1 : 0
  policy = templatefile("./modules/iam/templates/custom/ecr_set_scan_on_push.json.tpl", {})
  name   = "${upper(var.project)}CustodianECRSetScanOnPushPolicy${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "ecr_set_scan_on_push_lambda_policy_attach" {
  count      = var.ecr_set_scan_on_push == true ? 1 : 0
  role       = aws_iam_role.ecr_set_scan_on_push_role.*.id[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

resource "aws_iam_role_policy_attachment" "ecr_set_scan_on_push_policy_attach" {
  count      = var.ecr_set_scan_on_push == true ? 1 : 0
  policy_arn = aws_iam_policy.ecr_set_scan_on_push_policy.*.arn[0]
  role       = aws_iam_role.ecr_set_scan_on_push_role.*.id[0]
}