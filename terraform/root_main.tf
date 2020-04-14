module "global_parameters" {
  source = "./tdr-configurations/terraform"
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
}

module "sqs" {
  source            = "./modules/sqs"
  project           = var.project
  common_tags       = local.common_tags
  kms_master_key_id = module.encryption_key.kms_key_arn
}
