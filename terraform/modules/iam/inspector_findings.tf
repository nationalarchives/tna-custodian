resource "aws_iam_role_policy_attachment" "inspector_lambda_common_policy_attach" {
  count      = var.inspector == true ? 1 : 0
  role       = aws_iam_role.inspector_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

resource "aws_iam_role" "inspector_assume_role" {
  count              = var.inspector == true ? 1 : 0
  name               = "CustodianInspectorFindings"
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_policy" "inspector_policy" {
  count  = var.inspector == true ? 1 : 0
  name   = "${upper(var.project)}CustodianInspectorFindings${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/custom/inspector_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "inspector_policy_attach" {
  count      = var.inspector == true ? 1 : 0
  role       = aws_iam_role.inspector_assume_role.*.name[0]
  policy_arn = aws_iam_policy.inspector_policy.*.arn[0]
}
