locals {
  environment = lower(terraform.workspace)
  assume_role = local.environment == "mgmt" || local.environment == "sbox" || local.environment == "ddri" ? "arn:aws:iam::${var.tdr_account_number}:role/IAM_Admin_Role" : "arn:aws:iam::${var.tdr_account_number}:role/TDRTerraformRole${title(local.environment)}"
  common_tags = map(
    "Environment", local.environment,
    "Owner", upper(var.project),
    "Terraform", true,
    "CostCentre", module.global_parameters.cost_centre,
  )

}
