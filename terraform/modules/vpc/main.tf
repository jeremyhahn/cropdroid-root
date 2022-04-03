
module "log_bucket" {
  count         = var.create_log_bucket ? 1 : 0
  #source        = "../../modules/s3bucket"
  source        = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-s3bucket?ref=v0.0.1a"
  bucket_name   = var.log_bucket_name
  force_destroy = true
}

module "artifactrepo" {
  count         = var.create_artifact_repo ? 1 : 0
  #source        = "../../modules/s3bucket"
  source        = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-s3bucket?ref=v0.0.1a"
  bucket_name   = var.artifact_bucket_name
  target_prefix = "artifactrepo/"
  grants        = var.artifact_bucket_grants
  acl           = var.artifact_bucket_acl
  policy        = var.artifact_bucket_policy
  versioning    = var.artifact_bucket_versioning
  force_destroy = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 2.66.0"
  name = var.name
  cidr = var.cidr
  azs = var.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets
  intra_subnets    = var.intra_subnets

  create_database_subnet_group = false

  # One NAT Gateway per availability zone
  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  enable_vpn_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  #enable_ipv6          = true

  # VPC endpoint for S3
  #enable_s3_endpoint = true

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = [{}]
  default_security_group_egress  = [{}]

  public_subnet_tags   = merge(var.tags, {Name = "public-${var.env}"})
  private_subnet_tags  = merge(var.tags, {Name = "private-${var.env}"})
  database_subnet_tags = merge(var.tags, {Name = "database-${var.env}"})
  intra_subnet_tags    = merge(var.tags, {Name = "intra-${var.env}"})

  public_route_table_tags  = merge(var.tags, {Name = "public-${var.env}"})
  private_route_table_tags = merge(var.tags, {Name = "private-${var.env}"})
  intra_route_table_tags   = merge(var.tags, {Name = "intra-${var.env}"})

  tags = var.tags
}

module "bastion" {
  count                = var.create_bastion_host ? 1 : 0
  #source               = "../bastion"
  source               = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-bastion?ref=v0.0.1a"
  env                  = var.env
  vpc_id               = module.vpc.vpc_id
  log_bucket           = var.log_bucket_name
  asg_subnets          = module.vpc.public_subnets
  create_keypair       = var.create_bastion_keypair
  keypair_name         = var.bastion_keypair_name
  iam_instance_profile = var.bastion_iam_instance_profile
  userdata             = var.bastion_userdata
  volume_size          = var.bastion_volume_size
}

resource "aws_route53_zone" "internal" {
  name = var.internal_zone_name
  vpc {
    vpc_id = module.vpc.vpc_id
  }
  tags = var.tags
}

resource "aws_route53_zone" "external" {
  count = var.enable_managed_external_zone ? 0 : 1
  name  = var.enable_managed_external_zone ? data.aws_route53_zone.external_data[0].name : var.external_zone_name
  tags  = var.tags
}

data "aws_route53_zone" "external_data" {
  count = var.enable_managed_external_zone ? 1 : 0
  name  = "${var.external_zone_name}."
}
