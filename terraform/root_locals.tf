locals {
  environment = lower(terraform.workspace)

  common_tags = map(
    "Environment", local.environment,
    "Owner", upper(var.project),
    "Terraform", true,
    "CostCentre", module.global_parameters.cost_centre,
  )

}
