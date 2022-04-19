variable "name" {
  type        = string
  description = "The VPC name"
  default     = "cropdroid"
}

variable "env" {
  type        = string
  description = "Cloud environment (ie. dev, staging, prod)"
  default     = "stage"
}

variable "cidr" {
  type        = string
  description = "The network cidr for the vpc"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "The availability zones for the vpc"
  default     = ["us-east-1a", "us-east-1c", "us-east-1e"]
}

variable "public_subnets" {
  type        = list(string)
  description = "The vpc public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "The vpc private subnets"
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "database_subnets" {
  type        = list(string)
  description = "The vpc private subnets"
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "intra_subnets" {
  type        = list(string)
  description = "The vpc private subnets"
  default     = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]
}

variable "internal_zone_name" {
  type        = string
  description = "Internal route53 zone name for the vpc"
}

variable "external_zone_name" {
  type        = string
  description = "External route53 zone name for the vpc"
  default     = ""
}

variable "enable_managed_external_zone" {
  type        = bool
  description = "True to skip creating a new hosted zone for the passed external_zone_name (managed outside of terraform)"
  default     = false
}

variable "tags" {
  type        = map
  description = "Tags to assign to the vpc resources"
}

variable "artifact_bucket_name" {
  type        = string
  description = "S3 bucket to house logs for the vpc"
  default     = "cropdroid-artifacts-shared"
}

variable "artifact_bucket_acl" {
  type        = string
  description = "(Optional) The canned ACL to apply. Defaults to private. Conflicts with grant."
  default     = "private"
}

variable "artifact_bucket_policy" {
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide."
  type        = string
  default     = null
}

variable "artifact_bucket_versioning" {
  description = "Provides a resource for controlling versioning on an S3 bucket. Deleting this resource will either suspend versioning on the associated S3 bucket or simply remove the resource from Terraform state if the associated S3 bucket is unversioned. [Enabled | Disabled | Suspended]"
  type        = string
  default     = "Disabled"
}

variable "artifact_bucket_grants" {
  type        = any
  description = "(Optional) An ACL policy grant. Conflicts with acl."
  default     = []
}

variable "log_bucket_name" {
  type        = string
  description = "S3 bucket to house logs for the vpc"
  default     = "cropdroid-logs-shared"
}

variable "create_log_bucket" {
  type        = bool
  description = "True to create a S3 bucket for logs"
  default     = false
}

variable "create_artifact_repo" {
  type        = bool
  description = "True to create a S3 bucket for artifacts"
  default     = false
}

variable "bastion_keypair_name" {
  type        = string
  description = "The name of the keypair stored in EC2"
  default     = "bastion-stage"
}

variable "bastion_iam_instance_profile" {
  type        = string
  description = "The IAM instance profile to assign to the bastion EC2 instance"
  default     = ""
}

variable "bastion_userdata" {
  type        = string
  description = "The bastion instance user data"
  default     = null
}

variable "bastion_volume_size" {
  type        = string
  description = "The bastion server root block device volume size"
  default     = 8
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

variable "enable_vpn_gateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}
