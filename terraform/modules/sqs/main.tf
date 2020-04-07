resource "aws_sqs_queue" "custodian_mailer_queue" {
  count                     = var.project == "tdr" && local.environment != "mgmt" ? 0 : 1
  name                      = "custodian-mailer"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  kms_master_key_id         = var.kms_master_key_id
  tags = merge(
    var.common_tags,
    map(
      "Name", "custodian-mailer",
    )
  )
}

resource "aws_sqs_queue_policy" "multi_account" {
  count     = var.project == "tdr" && local.environment == "mgmt" ? 1 : 0
  queue_url = aws_sqs_queue.custodian_mailer_queue.*.id[0]
  policy = templatefile("./modules/sqs/templates/multi_account.json.tpl", { queue_arn = aws_sqs_queue.custodian_mailer_queue.*.arn[0], external_account_1 = data.aws_ssm_parameter.intg_account_number.*.value[0], external_account_2 = data.aws_ssm_parameter.staging_account_number.*.value[0], external_account_3 = data.aws_ssm_parameter.prod_account_number.*.value[0] })
}
