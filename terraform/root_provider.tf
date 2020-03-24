provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}
