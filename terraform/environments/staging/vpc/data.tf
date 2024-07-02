data "aws_caller_identity" "default" {}
data "aws_region" "current" {}

data "terraform_remote_state" "staging_bootstrap" {
  backend = "s3"
  config = {
    bucket  = "terraform-remote-state-342432848845"
    key     = "staging/bootstrap.tfstate"
    region  = var.region
    profile = var.profile
  }
}
