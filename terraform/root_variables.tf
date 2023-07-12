variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of resource names"
}

variable "account_number" {
  description = "The AWS account number where the project environment is hosted"
  type        = string
}

variable "assume_role" {
  description = "set to true to assume a project terraform role"
  default     = true
}
