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
  intg_account_number = data.aws_ssm_parameter.intg_account_number[0].value
  staging_account_number = data.aws_ssm_parameter.staging_account_number[0].value
  prod_account_number = data.aws_ssm_parameter.prod_account_number[0].value
}

module "sqs" {
  source            = "./modules/sqs"
  project           = var.project
  common_tags       = local.common_tags
  kms_master_key_id = module.encryption_key.kms_key_arn
  intg_account_number = data.aws_ssm_parameter.intg_account_number[0].value
  staging_account_number = data.aws_ssm_parameter.staging_account_number[0].value
  prod_account_number = data.aws_ssm_parameter.prod_account_number[0].value
}
