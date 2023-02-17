provider "aws" {
  region = "eu-west-2"

  dynamic "assume_role" {
    for_each = var.assume_tdr_role == true ? ["include_block"] : []
    content {
      role_arn     = local.assume_role
      session_name = "terraform"
      external_id  = module.global_parameters.external_ids.terraform_environments
    }
  }
}
