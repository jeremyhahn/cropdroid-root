data "aws_region" "current" {}

data "terraform_remote_state" "stage_bootstrap" {
  backend = "s3"
  config = {
    bucket  = "terraform-remote-state-342432848845"
    key     = "${var.env}/bootstrap.tfstate"
    region  = var.region
    profile = var.profile
  }
}

data "terraform_remote_state" "stage_vpc" {
  backend = "s3"
  config = {
    bucket  = "terraform-remote-state-342432848845"
    key     = "${var.env}/vpc.tfstate"
    region  = var.region
    profile = var.profile
  }
}

data "terraform_remote_state" "shared_pipeline_website" {
  backend = "s3"
  config = {
    bucket  = "terraform-remote-state-342432848845"
    key     = "shared/pipeline-website.tfstate"
    region  = var.region
    profile = var.profile
  }
}

data "aws_route53_zone" "external" {
  name         = local.external_dns_name
  private_zone = false
}
