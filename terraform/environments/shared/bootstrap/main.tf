
module "tagging" {
  source      = "../../../modules/tagging"
  #source      = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-tagging?ref=v0.0.1a"
  name        = var.name
  project     = "cropdroid"
  environment = var.env
  owner       = "devops"
  compliance  = "non-restricted"
}

module "remotestate" {
  source             = "../../../modules/remotestate"
  #source             = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-remotestate?ref=v0.0.1a"
  env                = var.env
  region             = var.region
  name               = "terraform-${var.env}"
  s3_bucket_name     = local.remotestate_bucket_name
  aws_dynamodb_table = local.remotestate_dynamodb_table
  tags               = module.tagging.tags
}
