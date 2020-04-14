resource "aws_iam_policy" "lambda_common_policy" {
  name   = "${upper(var.project)}CustodianLambdaCommon${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/common/lambda_common_policy.json.tpl", {})
}
