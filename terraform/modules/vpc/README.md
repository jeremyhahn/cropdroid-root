# VPC Module

This module creates a new VPC, logging bucket, artifact repository, bastion server and internal and external Route53 zones.


## Examples

```
module "tagging" {
  source      = "../modules/tagging"
  name        = "newlink"
  project     = "newlink"
  environment = var.env
  owner       = "devops"
  compliance  = "non-restricted"
}

module "vpc" {
  source             = "../modules/vpc"
  env                = var.env
  cidr               = var.cidr
  azs                = var.azs
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  internal_zone_name = var.internal_zone_name
  external_zone_name = var.external_zone_name
  tags               = module.tagging.tags
}

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| env | The application environment (stage, rc, prod) | string | `stage` | yes |
| cidr | The network CIDR for the VPC | string | `10.0.0.0/16` | yes |
| azs | List of availability zones to assign to the VPC | list(string) | `["us-east-1a", "us-east-1c", "us-east-1e"]` | yes |
| public_subnets | The vpc public subnets | list(string) | `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]` | yes |
| private_subnets | The vpc private subnets | list(string) | ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"] | yes |
| internal_zone_name | Internal route53 zone name for the vpc | string | - | yes |
| external_zone_name | External route53 zone name for the vpc | string | - | yes |
| tags | Mapping of common tags for AWS resources | string | - | yes |
| log_bucket | S3 bucket to house logs for the vpc | string | `newlink-logs` | yes |


## Outputs

| Name | Description |
|------|-------------|
| vpc\_id | The VPC unique identifier |
| public_subnets | The vpc public subnets |
| private_subnets | The vpc private subnets |
| public_cidrs | The public network CIDRs assigned to each of the AZs |
| private_cidrs | The private network CIDRs assigned to each of the AZs |
| internal_dns_name | Internal route53 zone name for the vpc |
| internal_dns_zone_id | The Route53 hosted zone id for the internal DNS zone |
| external_dns_name | External route53 zone name for the vpc |
| external_dns_zone_id | The Route53 hosted zone id for the external DNS zone |
| nat_public_ips | The IP addresses of the NAT gateways assigned to each of the AZs |
| s3_artifact_repo | The S3 bucket where devops and software artifacts are stored |
| s3_log_bucket | S3 bucket to house logs for the vpc |
