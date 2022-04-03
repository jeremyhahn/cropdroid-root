
variable "env" {
  type        = string
  description = "Application environment (ie. stage, rc, prod)"
  default     = "staging"
}

variable "profile" {
  type        = string
  description = "Name of AWS credentials profile context to use for authentication"
  default     = "cropdroid-staging"
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "website_bucket" {
  type        = string
  description = "The name of the s3 static website bucket (without the www.) prefix."
  default     = "staging.cropdroid.com"
}

variable "enable_health_checks" {
  description = "Turn Route 53 health checks on/off"
  type        = bool
  default     = false
}

variable "enable_waf" {
  type        = bool
  description = "Turn Web Application Firewall (WAF) on/off"
  default     = false
}

locals {
  external_dns_zone_id = data.terraform_remote_state.stage_vpc.outputs.external_dns_zone_id
  external_dns_name    = data.terraform_remote_state.stage_vpc.outputs.external_dns_name

  subject_alternative_names = [
    "www.${local.external_dns_name}"
  ]

  sns_topic_arn = data.terraform_remote_state.stage_bootstrap.outputs.infrastructure_sns_topic

  tags = data.terraform_remote_state.stage_bootstrap.outputs.tags
}
