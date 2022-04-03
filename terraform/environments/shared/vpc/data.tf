data "aws_canonical_user_id" "current" {}
data "aws_caller_identity" "default" {}

data "terraform_remote_state" "shared_services" {
  backend = "local"
  config = {
    path = "../bootstrap/terraform.tfstate"
  }
}

// TODO: day 2 support
data "terraform_remote_state" "stage_bootstrap" {
  backend = "local"
  config = {
    path = "../../staging/bootstrap/terraform.tfstate"
  }
}

# data "terraform_remote_state" "stage_bootstrap" {
#   backend = "local"
#   config = {
#     path = "../../prod/bootstrap/terraform.tfstate"
#   }
# }
