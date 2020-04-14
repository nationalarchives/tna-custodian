variable "common_tags" {
  description = "tags used across the project"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the resource name"
}

variable "kms_master_key_id" {
  description = "ID of an AWS managed key or customer managed key"
  default     = "alias/aws/sqs"
}
