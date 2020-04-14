locals {
  workspace   = lower(terraform.workspace)
  environment = local.workspace == "default" ? "mgmt" : local.workspace
}

locals {
  kms_key_id = var.project == "tdr" && local.environment == "mgmt" ? aws_kms_key.encryption.*.arn[0] : ""
}