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

variable "ec2_mark_unencrypted" {
  description = "Deploy IAM role for EC2 mark unencrypted policy"
  default     = true
}

variable "ec2_unmark_encrypted" {
  description = "Deploy IAM role for EC2 unmark encrypted policy"
  default     = true
}

variable "ec2_delete_marked" {
  description = "Deploy IAM role for EC2 delete marked policy"
  default     = true
}

variable "guard_duty_notify" {
  description = "Notify on Guard Duty findings"
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

variable "s3_mark_unencrypted" {
  description = "Deploy IAM role for S3 mark unencrypted policy"
  default     = true
}

variable "s3_unmark_encrypted" {
  description = "Deploy IAM role for S3 unmark encrypted policy"
  default     = true
}

variable "s3_delete_marked" {
  description = "Deploy IAM role for S3 delete marked policy"
  default     = true
}

variable "s3_public_access" {
  description = "Deploy IAM role for S3 public access policy"
  default     = true
}

variable "s3_remove_public_acl" {
  description = "Deploy IAM role for S3 remove public acl policy"
  default     = true
}

variable "ec2_mark_no_flow_logs" {
  description = "Deploy IAM role for VPC mark no flow logs policy"
  default     = true
}

variable "ec2_unmark_flow_logs" {
  description = "Deploy IAM role for VPC unmark flow logs policy"
  default     = true
}

variable "ec2_delete_vpc" {
  description = "Deploy IAM role for deleting marked VPC policy"
  default     = true
}

variable "s3_check_public_block" {
  description = "Deploy IAM role for S3 check public block policy"
  default     = true
}
