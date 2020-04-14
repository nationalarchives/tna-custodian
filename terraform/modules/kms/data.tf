data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "intg_account_number" {
  count = var.project == "tdr" && local.environment == "mgmt" ? 1 : 0
  name  = "/mgmt/intg_account"
}

data "aws_ssm_parameter" "staging_account_number" {
  count = var.project == "tdr" && local.environment == "mgmt" ? 1 : 0
  name  = "/mgmt/staging_account"
}

data "aws_ssm_parameter" "prod_account_number" {
  count = var.project == "tdr" && local.environment == "mgmt" ? 1 : 0
  name  = "/mgmt/prod_account"
}
