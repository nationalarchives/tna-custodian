locals {
  inspector_count      = var.inspector == true ? 1 : 0
  inspector_role_name  = aws_iam_role.inspector_assume_role.*.name[0]
  inspector_policy_arn = aws_iam_policy.inspector_policy.*.arn[0]
}
resource "aws_iam_role_policy_attachment" "inspector_lambda_common_policy_attach" {
  count      = local.inspector_count
  role       = local.inspector_role_name
  policy_arn = local.inspector_policy_arn
}

resource "aws_iam_role" "inspector_assume_role" {
  count              = local.inspector_count
  name               = "CustodianInspectorFindings"
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_policy" "inspector_policy" {
  count  = local.inspector_count
  name   = "${upper(var.project)}CustodianInspectorFindings${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/custom/inspector_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "inspector_policy_attach" {
  count      = local.inspector_count
  role       = local.inspector_role_name
  policy_arn = local.inspector_policy_arn
}
