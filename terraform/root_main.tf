module "global_parameters" {
  source = "./tdr-configurations/terraform"
}

module "iam" {
  source      = "./modules/iam"
  project     = var.project
  common_tags = local.common_tags
}

module "sqs" {
  source      = "./modules/sqs"
  project     = var.project
  common_tags = local.common_tags
  providers = {
    aws = aws.eu-west-1
  }
}
