variable "common_tags" {
  description = "tags used across the project"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the resource name"
}

variable "cloudtrail_detect_root_login" {
  description = "Detect root login to the console"
  default     = true
}

variable "ec2_sg_ingress_ssh" {
  description = "Deploy IAM role for EC2 Security Group ingress SSH policy"
  default     = true
}

variable "iam_access_key_delete" {
  description = "Deploy IAM role for IAM Access Key Delete policy"
  default     = true
}

variable "iam_access_key_disable" {
  description = "Deploy IAM role for IAM Access Key Disable policy"
  default     = true
}

variable "iam_access_key_warn" {
  description = "Deploy IAM role for IAM Access Key Warn policy"
  default     = true
}

variable "iam_mfa_warn" {
  description = "Deploy IAM role for IAM MFA Warn policy"
  default     = true
}

variable "mailer" {
  description = "Deploy IAM role for mailer"
  default     = true
}
