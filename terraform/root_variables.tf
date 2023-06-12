variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of resource names"
}

variable "account_number" {
  description = "The AWS account number where the TDR environment is hosted"
  type        = string
}

variable "assume_role" {
  description = "set to true to assume a TDR terraform role"
  default     = true
}
