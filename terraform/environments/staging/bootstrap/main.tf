
# Use an SCP at the organizational level to require a cost center tag be applied to every resource.
# Activate the cost center tag in the Billing Console and allocate costs based on that.
module "tagging" {
  source      = "../../../modules/tagging"
  #source      = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-tagging?ref=v0.0.1a"
  name        = "cropdroid-staging"
  project     = "cropdroid"
  environment = local.env
  owner       = "cropdroid"
  compliance  = "restricted"
}

module "remotestate" {
  source                 = "../../../modules/remotestate"
  #source                = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-remotestate?ref=v0.0.1a"
  create_lock_table_only = true
  env                    = local.env
  region                 = local.region
  name                   = "terraform-${local.env}"
  aws_dynamodb_table     = local.remotestate_dynamodb_table
  tags                   = module.tagging.tags
}
