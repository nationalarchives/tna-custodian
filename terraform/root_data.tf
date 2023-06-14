data "aws_ssm_parameter" "intg_account_number" {
  count = local.environment == "mgmt" ? 1 : 0
  name  = local.account_parameter_names[var.project]["intg"]
}

data "aws_ssm_parameter" "staging_account_number" {
  count = local.environment == "mgmt" ? 1 : 0
  name  = local.account_parameter_names[var.project]["staging"]
}

data "aws_ssm_parameter" "prod_account_number" {
  count = local.environment == "mgmt" ? 1 : 0
  name  = local.account_parameter_names[var.project]["prod"]
}
