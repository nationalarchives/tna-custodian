resource "aws_sqs_queue" "custodian_mailer_queue" {
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
