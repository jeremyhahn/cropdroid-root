variable "env" {
  type        = string
  description = "Application environment (ie. stage, rc, prod)"
  default     = "shared"
}

variable "profile" {
  type        = string
  description = "Name of AWS credentials profile context to use for authentication"
  default     = "cropdroid-shared"
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

locals {
  artifact_repo   = data.terraform_remote_state.vpc.outputs.s3_artifact_repo
  artifact_name   = "service-website.zip"

  infra_sns_topic = data.terraform_remote_state.shared_bootstrap.outputs.infrastructure_sns_topic

  lambda_bucket_arn = data.terraform_remote_state.vpc.outputs.s3_artifact_repo_arn
  lambda_filename = "${path.module}/files/lambda.zip"
  lambda_env_vars = {
    "REGION" = data.aws_region.current.name
    "TARGET_BUCKET" = local.artifact_repo
    "TARGET_KEY" = local.artifact_name
    "NOTIFICATION_ARN" = local.infra_sns_topic
  }

  tags = data.terraform_remote_state.shared_bootstrap.outputs.tags
}
