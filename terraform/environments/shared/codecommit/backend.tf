provider "aws" {
  profile = var.profile
  region  = var.region
}

terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "terraform-remote-state-342432848845"
    key            = "shared/codecommit.tfstate"
    encrypt        = true
    dynamodb_table = "terraform-remote-state-locks"
  }
}
