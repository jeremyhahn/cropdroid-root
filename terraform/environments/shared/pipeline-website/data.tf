data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "terraform_remote_state" "shared_bootstrap" {
  backend = "local"
  config = {
    path = "../bootstrap/terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = "terraform-remote-state-342432848845"
    key     = "${var.env}/vpc.tfstate"
    region  = var.region
    profile = var.profile
  }
}
