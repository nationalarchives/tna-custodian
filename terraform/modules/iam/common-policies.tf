data "template_file" "lambda_common_policy" {
  template = file("./modules/iam/templates/common/lambda_common_policy.json.tpl")
}

resource "aws_iam_policy" "lambda_common_policy" {
  name   = "${upper(var.project)}CustodianLambdaCommon${title(local.environment)}"
  policy = data.template_file.lambda_common_policy.rendered
}
