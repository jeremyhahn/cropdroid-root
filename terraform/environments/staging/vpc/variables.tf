variable "name" {
  type        = string
  description = "The VPC name"
  default     = "cropdroid-staging"
}

variable "env" {
  type        = string
  description = "Application environment (ie. stage, rc, staging)"
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

variable "cidr" {
  type        = string
  description = "The network cidr for the vpc"
  default     = "10.2.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "The availability zones for the vpc"
  default     = ["us-east-1a", "us-east-1c", "us-east-1e"]
}

variable "public_subnets" {
  type        = list(string)
  description = "The vpc public subnets"
  default     = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "The vpc private subnets"
  default     = ["10.2.20.0/24", "10.2.21.0/24", "10.2.22.0/24"]
}

variable "database_subnets" {
  type        = list(string)
  description = "The vpc database subnets"
  default     = ["10.2.30.0/24", "10.2.31.0/24", "10.2.32.0/24"]
}

variable "intra_subnets" {
  type        = list(string)
  description = "The vpc intra (host only) subnets"
  default     = ["10.2.40.0/24", "10.2.41.0/24", "10.2.42.0/24"]
}

variable "internal_zone_name" {
  type        = string
  description = "Internal route53 zone name for the vpc"
  default     = "cropdroid-staging.internal"
}

variable "external_zone_name" {
  type        = string
  description = "External route53 zone name for the vpc"
  default     = "staging.cropdroid.com"
}

variable "tags" {
  type        = map
  description = "Tags to assign to the vpc resources"
  default     = {}
}

variable "log_bucket" {
  type        = string
  description = "S3 bucket to house logs for the vpc"
  default     = "cropdroid-logs"
}

variable "bastion_keypair_name" {
  type        = string
  description = "The name of the keypair stored in EC2"
  default     = "bastion-staging"
}

variable "create_bastion_host" {
  type        = bool
  description = "True to create a terraform managed bastion host"
  default     = false
}

variable "create_bastion_keypair" {
  type        = bool
  description = "True to create a terraform managed keypair, false to skip key creation and use an existing key"
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  type        = bool
  default     = true
}

locals {
  env     = var.env
  profile = var.profile
  region  = var.region

  remotestate_dynamodb_table = "terraform-remote-state-locks"

  tags = data.terraform_remote_state.staging_bootstrap.outputs.tags
}
