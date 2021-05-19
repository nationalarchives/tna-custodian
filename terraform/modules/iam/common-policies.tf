resource "aws_iam_policy" "lambda_common_policy" {
  name   = "${upper(var.project)}CustodianLambdaCommon${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/common/lambda_common_policy.json.tpl", {})
}

resource "aws_iam_policy" "lambda_vpc_access_execution" {
  name   = "${upper(var.project)}CustondialLambdaVpcAccessExecution${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/common/lambda_vpc_access_execution.json.tpl", {})
}
