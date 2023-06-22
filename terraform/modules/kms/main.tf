resource "aws_kms_key" "encryption" {
  count               = local.environment == "mgmt" ? 1 : 0
  description         = "KMS key for Cloud Custodian SQS queue encryption"
  enable_key_rotation = true
  policy              = templatefile("./modules/kms/templates/multi_account.json.tpl", { account_id = data.aws_caller_identity.current.account_id, external_account_1 = var.intg_account_number, external_account_2 = var.staging_account_number, external_account_3 = var.prod_account_number })
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
  count         = local.environment == "mgmt" ? 1 : 0
  name          = "alias/${var.project}-${var.function}-${var.environment}"
  target_key_id = aws_kms_key.encryption.*.key_id[0]
}
