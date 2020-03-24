locals {
  workspace   = lower(terraform.workspace)
  environment = local.workspace == "default" ? "mgmt" : local.workspace
}