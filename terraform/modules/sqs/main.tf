resource "aws_sqs_queue" "custodian_mailer_queue" {
  count                     = local.environment != "mgmt" ? 0 : 1
  name                      = "custodian-mailer"
  delay_seconds             = 90
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  kms_master_key_id         = var.kms_master_key_id
  tags = merge(
    var.common_tags,
    tomap(
      {
        "Name" = "custodian-mailer"
      }
    )
  )
}

resource "aws_sqs_queue_policy" "multi_account" {
  count     = local.environment == "mgmt" ? 1 : 0
  queue_url = aws_sqs_queue.custodian_mailer_queue.*.id[0]
  policy    = templatefile("./modules/sqs/templates/multi_account.json.tpl", { queue_arn = aws_sqs_queue.custodian_mailer_queue.*.arn[0], external_account_1 = var.intg_account_number, external_account_2 = var.staging_account_number, external_account_3 = var.prod_account_number })
}
