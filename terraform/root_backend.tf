terraform {
  backend "s3" {
    key     = "custodian.state"
    region  = "eu-west-2"
    encrypt = true
  }
}
