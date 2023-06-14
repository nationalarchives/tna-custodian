locals {
  environment = lower(terraform.workspace)
  assume_role = var.project == "dr2" ? "arn:aws:iam::${var.account_number}:role/${title(local.environment)}TerraformRole" : local.environment == "mgmt" || local.environment == "sbox" || local.environment == "ddri" ? "arn:aws:iam::${var.account_number}:role/IAM_Admin_Role" : "arn:aws:iam::${var.account_number}:role/TDRTerraformRole${title(local.environment)}"
  common_tags = tomap(
    {
      "Environment" = local.environment,
      "Owner"       = upper(var.project),
      "Terraform"   = true,
      "CostCentre"  = module.global_parameters.cost_centre
    }
  )
  account_parameter_names = {
    tdr = {
      intg = "/mgmt/intg_account"
      staging = "/mgmt/staging_account"
      prod = "/mgmt/prod_account"
    }
    dr2 = {
      intg = "/mgmt/intg_account_number"
      staging = "/mgmt/staging_account_number"
      prod = "/mgmt/prod_account_number"
    }
  }
}
