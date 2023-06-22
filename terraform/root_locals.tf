locals {
  environment = lower(terraform.workspace)
  assume_role = module.terraform_config.terraform_config[local.environment]["terraform_account_role"]
  common_tags = tomap(
    {
      "Environment" = local.environment,
      "Owner"       = upper(var.project),
      "Terraform"   = true,
      "CostCentre"  = module.terraform_config.terraform_config["cost_centre"]
    }
  )
}
