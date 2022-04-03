# Use an SCP at the organizational level to require a cost center tag be applied to every resource.
# Activate the cost center tag in the Billing Console and allocate costs based on that.
module "tagging" {
  source      = "../../../modules/tagging"
  #source      = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-tagging?ref=v0.0.1a"
  name        = "cropdroid-mgmt"
  project     = "cropdroid"
  environment = local.env
  owner       = "cropdroid"
  compliance  = "restricted"
}

module "remotestate" {
  source             = "../../../modules/remotestate"
  #source             = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-remotestate?ref=v0.0.1a"
  env                = local.env
  region             = local.region
  name               = "terraform-${local.env}"
  s3_bucket_name     = local.remotestate_bucket_name
  aws_dynamodb_table = local.remotestate_dynamodb_table
  tags               = module.tagging.tags
}

# module "aft" {
#   source = "github.com/aws-ia/terraform-aws-control_tower_account_factory"
#   ct_management_account_id    = "288834285707"
#   log_archive_account_id      = "695529858312"
#   audit_account_id            = "695357733671"
#   aft_management_account_id   = "685454867570"
#   ct_home_region              = "us-east-1"
#   tf_backend_secondary_region = "us-west-2"
# }
