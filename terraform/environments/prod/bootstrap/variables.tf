variable "env" {
  type        = string
  description = "Application environment (ie. stage, rc, prod)"
  default     = "prod"
}

variable "profile" {
  type        = string
  description = "Name of AWS credentials profile context to use for authentication"
  default     = "cropdroid-prod"
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

locals {
  env     = var.env
  profile = var.profile
  region  = var.region

  account_id = data.aws_caller_identity.current.account_id

  remotestate_dynamodb_table = "terraform-remote-state-locks"

  infrastructure_alert_email = "mail@jeremyhahn.com"
}
