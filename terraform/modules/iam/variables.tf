variable "common_tags" {
  description = "tags used across the project"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the resource name"
}

variable "iam_mfa_warn" {
  description = "Deploy IAM role for IAM MFA Warn policy"
  default     = true
}

variable "mailer" {
  description = "Deploy IAM role for mailer"
  default     = true
}
