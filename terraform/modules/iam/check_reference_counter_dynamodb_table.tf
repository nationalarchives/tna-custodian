resource "aws_iam_role" "check_da_reference_counter_assume_role" {
  count              = var.reference_counter_check == true ? 1 : 0
  name               = "CustodianCheckReferenceCounterDynamoDbTable"
  assume_role_policy = templatefile("./modules/iam/templates/common/assume_role_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  count      = var.reference_counter_check == true ? 1 : 0
  role       = aws_iam_role.check_da_reference_counter_assume_role.*.name[0]
  policy_arn = aws_iam_policy.lambda_common_policy.*.arn[0]
}

resource "aws_iam_role_policy_attachment" "policy_attachment_1" {
  count      = var.reference_counter_check == true ? 1 : 0
  role       = aws_iam_role.check_da_reference_counter_assume_role.*.name[0]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}
