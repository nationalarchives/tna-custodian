provider "aws" {
  region = "eu-west-2"

  dynamic "assume_role" {
    for_each = var.assume_role == true ? ["include_block"] : []
    content {
      role_arn     = local.assume_role
      session_name = "terraform"
      external_id  = var.project == "tdr" ? module.global_parameters.external_ids.terraform_environments : null
    }
  }
}
