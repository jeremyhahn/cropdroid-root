
variable "env" {
  description = "Deployment environment"
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "branch" {
  description = "Repository branch to connect to"
  default     = "master"
}

variable "github_org" {
  description = "GitHub repository organization name"
  default     = "example-org"
}

variable "owner" {
  description = "GitHub repository owner"
  default     = "example-owner"
}

variable "repository_name" {
  description = "GitHub repository name"
  default     = "example-repo"
}

variable "artifact_bucket" {
  description = "S3 Bucket for storing artifacts"
  default     = "artifacts-bucket"
}

variable "codestar_connection_arn" {
  type        = string
  description = "The ARN of the AWS CodeStar connection configured to access the github repository"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to module resources"
  default     = {}
}

variable "extra_permissions" {
  type        = list(any)
  default     = []
  description = "List of action strings which will be added to IAM service account permissions."
}

variable "codebuild_image" {
  type = string
  description = "The shared codebuild runtime environment used to build an x86 and aarch64 images"
  default = ""
}

variable "codebuild_image_x86" {
  type = string
  description = "The codebuild runtime environment used to build an x86 image"
  default = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

variable "codebuild_image_aarch64" {
  type = string
  description = "The codebuild runtime environment used to build an aarch64 (ARM64) image"
  default = "aws/codebuild/amazonlinux2-aarch64-standard:2.0"
}

variable "codebuild_compute" {
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
  description = "A supported codebuild compute environment. https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html"
}

variable "environment_variables" {
  type = list(object(
    {
      name  = string
      value = string
  }))

  default = []

  description = "A list of maps, that contain both the key 'name' and the key 'value' to be used as additional environment variables for the build"
}

variable "buildspec_template" {
  type        = string
  description = "The file path to the codebuild buildspec file"
  default     = "files/buildspec.yml"
}

variable "disable_naming_convention" {
  type        = bool
  description = "Disables appending branch and environment to repository name"
  default     = false
}

variable "dockerhub_secret_arn" {
  type        = string
  description = "AWS Secrets Manager ARN that stores hub.docker.com credentials"
}

locals {
  final_repository_name = var.disable_naming_convention ? var.repository_name : "${var.repository_name}-${var.branch}-${var.env}"
}
