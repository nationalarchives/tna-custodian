resource "aws_iam_role_policy_attachment" "guard_duty_notify_lambda_common_policy_attach" {
  count      = var.guard_duty_notify == true ? 1 : 0
  role       = aws_iam_role.guard_duty_notify_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

resource "aws_iam_role" "guard_duty_notify_assume_role" {
  count              = var.guard_duty_notify == true ? 1 : 0
  name               = "CustodianGuardDutyNotify"
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_policy" "guard_duty_notify_policy" {
  count  = var.guard_duty_notify == true ? 1 : 0
  name   = "${upper(var.project)}CustodianGuardDutyNotify${title(local.environment)}"
  policy = templatefile("./modules/iam/templates/custom/guard-duty-notify/guard_duty_notify_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "guard_duty_notify_policy_attach" {
  count      = var.guard_duty_notify == true ? 1 : 0
  role       = aws_iam_role.guard_duty_notify_assume_role.*.name[0]
  policy_arn = aws_iam_policy.guard_duty_notify_policy.*.arn[0]
}
