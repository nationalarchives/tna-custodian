provider "aws" {
  region = "eu-west-2"

  dynamic "assume_role" {
    for_each = var.assume_role == true ? ["include_block"] : []
    content {
      role_arn     = local.assume_role
      session_name = "terraform"
      external_id  = module.terraform_config.terraform_config[local.environment]["terraform_external_id"]
    }
  }
}
