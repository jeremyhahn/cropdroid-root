data "terraform_remote_state" "root_bootstrap" {
  backend = "local"

  config = {
    path = "../bootstrap/terraform.tfstate"
  }
}
