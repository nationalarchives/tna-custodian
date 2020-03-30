resource "aws_iam_role_policy_attachment" "iam_access_key_disable_lambda_common_policy_attach" {
  count  = var.iam_access_key_disable == true ? 1 : 0
  role       = aws_iam_role.iam_access_key_disable_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

data "template_file" "iam_access_key_disable_assume_role_policy" {
  template = file("./modules/iam/templates/common/assume_role_policy.json.tpl")
}

resource "aws_iam_role" "iam_access_key_disable_assume_role" {
  count              = var.iam_access_key_disable == true ? 1 : 0
  name               = "CustodianIamAccessKeyDisable"
  assume_role_policy = data.template_file.iam_access_key_disable_assume_role_policy.rendered
}

data "template_file" "iam_access_key_disable_policy" {
  template = file("./modules/iam/templates/custom/iam-access-key/iam_access_key_policy.json.tpl")
}

resource "aws_iam_policy" "iam_access_key_disable_policy" {
  count  = var.iam_access_key_disable == true ? 1 : 0
  name   = "${upper(var.project)}CustodianIamAccessKeyDisable${title(local.environment)}"
  policy = data.template_file.iam_access_key_disable_policy.rendered
}

resource "aws_iam_role_policy_attachment" "iam_access_key_disable_policy_attach" {
  count  = var.iam_access_key_disable == true ? 1 : 0
  role       = aws_iam_role.iam_access_key_disable_assume_role.*.name[0]
  policy_arn = aws_iam_policy.iam_access_key_disable_policy.*.arn[0]
}
