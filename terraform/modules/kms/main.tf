resource "aws_kms_key" "encryption" {
  count               = var.project == "tdr" && local.environment == "mgmt" ? 1 : 0
  description         = "KMS key for Cloud Custodian SQS queue encryption"
  enable_key_rotation = true
  policy              = templatefile("./modules/kms/templates/multi_account.json.tpl", { account_id = data.aws_caller_identity.current.account_id, external_account_1 = data.aws_ssm_parameter.intg_account_number.*.value[0], external_account_2 = data.aws_ssm_parameter.staging_account_number.*.value[0], external_account_3 = data.aws_ssm_parameter.prod_account_number.*.value[0] })
  tags = merge(
    var.common_tags,
    tomap(
      {
        "Name" = "${var.project}-${var.function}-${var.environment}"
      }
    )
  )
}

resource "aws_kms_alias" "encryption" {
  count         = var.project == "tdr" && local.environment == "mgmt" ? 1 : 0
  name          = "alias/${var.project}-${var.function}-${var.environment}"
  target_key_id = aws_kms_key.encryption.*.key_id[0]
}
