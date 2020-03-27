data "template_file" "iam_access_key_warn_assume_role_policy" {
  template = file("./modules/iam/templates/common/assume_role_policy.json.tpl")
}

resource "aws_iam_role" "iam_access_key_warn_assume_role" {
  count              = var.iam_access_key_warn == true ? 1 : 0
  name               = "CustodianIamAccessKeyWarn"
  assume_role_policy = data.template_file.iam_access_key_warn_assume_role_policy.rendered
}

data "template_file" "iam_access_key_warn_policy" {
  template = file("./modules/iam/templates/custom/iam-access-key/iam_access_key_policy.json.tpl")
}

resource "aws_iam_policy" "iam_access_key_warn_policy" {
  count  = var.iam_access_key_warn == true ? 1 : 0
  name   = "${upper(var.project)}CustodianIamAccessKeyWarn${title(local.environment)}"
  policy = data.template_file.iam_access_key_warn_policy.rendered
}

resource "aws_iam_role_policy_attachment" "iam_access_key_warn_policy_attach" {
  count  = var.iam_access_key_warn == true ? 1 : 0
  role       = aws_iam_role.iam_access_key_warn_assume_role.*.name[0]
  policy_arn = aws_iam_policy.iam_access_key_warn_policy.*.arn[0]
}

data "template_file" "iam_access_key_warn_lambda_common_policy" {
  template = file("./modules/iam/templates/common/lambda_common_policy.json.tpl")
}

resource "aws_iam_policy" "iam_access_key_warn_lambda_common_policy" {
  count  = var.iam_access_key_warn == true ? 1 : 0
  name   = "${upper(var.project)}CustodianIamAccessKeyWarnLambdaCommon${title(local.environment)}"
  policy = data.template_file.iam_access_key_warn_lambda_common_policy.rendered
}

resource "aws_iam_role_policy_attachment" "iam_access_key_warn_lambda_common_policy_attach" {
  count  = var.iam_access_key_warn == true ? 1 : 0
  role       = aws_iam_role.iam_access_key_warn_assume_role.*.name[0]
  policy_arn = aws_iam_policy.iam_access_key_warn_lambda_common_policy.*.arn[0]
}