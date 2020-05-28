resource "aws_iam_role_policy_attachment" "cloudtrail_detect_root_login_lambda_common_policy_attach" {
  count      = var.cloudtrail_detect_root_login == true ? 1 : 0
  role       = aws_iam_role.cloudtrail_detect_root_login_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

resource "aws_iam_role" "cloudtrail_detect_root_login_assume_role" {
  count              = var.cloudtrail_detect_root_login == true ? 1 : 0
  name               = "CustodianCloudtrailDetectRootLogin"
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_policy" "cloudtrail_detect_root_login_policy" {
  count  = var.cloudtrail_detect_root_login == true ? 1 : 0
  name   = "${upper(var.project)}CustodianCloudtrailDetectRootLogin${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/custom/cloudtrail_detect_root_login_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "cloudtrail_detect_root_login_policy_attach" {
  count      = var.cloudtrail_detect_root_login == true ? 1 : 0
  role       = aws_iam_role.cloudtrail_detect_root_login_assume_role.*.name[0]
  policy_arn = aws_iam_policy.cloudtrail_detect_root_login_policy.*.arn[0]
}
