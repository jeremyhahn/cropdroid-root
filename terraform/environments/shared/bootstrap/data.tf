data "aws_caller_identity" "current" {}
data "aws_canonical_user_id" "current" {}

data "terraform_remote_state" "root_bootstrap" {
  backend = "local"

  config = {
    path = "../../root/bootstrap/terraform.tfstate"
  }
}
