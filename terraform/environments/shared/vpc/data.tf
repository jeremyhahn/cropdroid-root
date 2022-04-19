data "aws_canonical_user_id" "current" {}
data "aws_caller_identity" "default" {}

data "terraform_remote_state" "shared_services" {
  backend = "local"
  config = {
    path = "../bootstrap/terraform.tfstate"
  }
}

// TODO: day 2 support
# data "terraform_remote_state" "stage_bootstrap" {
#   backend = "local"
#   config = {
#     path = "../../staging/bootstrap/terraform.tfstate"
#   }
# }

data "terraform_remote_state" "stage_bootstrap" {
  backend = "s3"
  config = {
    bucket  = "terraform-remote-state-342432848845"
    key     = "staging/bootstrap.tfstate"
    region  = var.region
    profile = var.profile
  }
}

data "terraform_remote_state" "prod_bootstrap" {
  backend = "s3"
  config = {
    bucket  = "terraform-remote-state-342432848845"
    key     = "prod/bootstrap.tfstate"
    region  = var.region
    profile = var.profile
  }
}


# data "terraform_remote_state" "prod_bootstrap" {
#   backend = "local"
#   config = {
#     path = "../../prod/bootstrap/terraform.tfstate"
#   }
# }
