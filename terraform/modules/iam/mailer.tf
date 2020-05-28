data "template_file" "mailer_assume_role_policy" {
  template = file("./modules/iam/templates/common/assume_role_policy.json.tpl")
}

resource "aws_iam_role" "mailer_assume_role" {
  count              = var.mailer == true ? 1 : 0
  name               = "CustodianMailer"
  assume_role_policy = data.template_file.mailer_assume_role_policy.rendered
}

data "template_file" "mailer_lambda_common_policy" {
  template = file("./modules/iam/templates/common/lambda_common_policy.json.tpl")
}

resource "aws_iam_policy" "mailer_lambda_common_policy" {
  count  = var.mailer == true ? 1 : 0
  name   = "${upper(var.project)}CustodianMailerLambdaCommon${title(local.environment)}"
  policy = data.template_file.mailer_lambda_common_policy.rendered
}

resource "aws_iam_role_policy_attachment" "mailer_lambda_common_policy_attach" {
  count      = var.mailer == true ? 1 : 0
  role       = aws_iam_role.mailer_assume_role.*.name[0]
  policy_arn = aws_iam_policy.mailer_lambda_common_policy.*.arn[0]
}

data "template_file" "mailer_policy" {
  template = file("./modules/iam/templates/custom/mailer_policy.json.tpl")
}

resource "aws_iam_policy" "mailer_policy" {
  count  = var.iam_mfa_warn == true ? 1 : 0
  name   = "${upper(var.project)}CustodianMailer${title(local.environment)}"
  policy = data.template_file.mailer_policy.rendered
}

resource "aws_iam_role_policy_attachment" "mailer_policy_attach" {
  count      = var.iam_mfa_warn == true ? 1 : 0
  role       = aws_iam_role.mailer_assume_role.*.name[0]
  policy_arn = aws_iam_policy.mailer_policy.*.arn[0]
}
