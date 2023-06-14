module "global_parameters" {
  source = "./tdr-configurations/terraform"
}

module "terraform_config" {
  source = "git::https://github.com/nationalarchives/da-terraform-configurations//?ref=create-terraform-config"
  project = var.project
}

module "iam" {
  source      = "./modules/iam"
  project     = var.project
  common_tags = local.common_tags
}

module "encryption_key" {
  source      = "./modules/kms"
  project     = var.project
  environment = local.environment
  common_tags = local.common_tags
  function    = "sqs"
  key_policy  = "multi_account"
  intg_account_number = module.terraform_config.account_numbers["intg"]
  staging_account_number = module.terraform_config.account_numbers["staging"]
  prod_account_number = module.terraform_config.account_numbers["prod"]
}

module "sqs" {
  source            = "./modules/sqs"
  project           = var.project
  common_tags       = local.common_tags
  kms_master_key_id = module.encryption_key.kms_key_arn
  intg_account_number = module.terraform_config.account_numbers["intg"]
  staging_account_number = module.terraform_config.account_numbers["staging"]
  prod_account_number = module.terraform_config.account_numbers["prod"]
}
