data "aws_ssm_parameter" "intg_account_number" {
  name  = local.account_parameter_names[var.project]["intg"]
}

data "aws_ssm_parameter" "staging_account_number" {
  name  = local.account_parameter_names[var.project]["staging"]
}

data "aws_ssm_parameter" "prod_account_number" {
  name  = local.account_parameter_names[var.project]["prod"]
}
