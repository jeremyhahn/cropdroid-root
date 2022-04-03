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

variable "owner" {
  description = "GitHub repository owner"
  default     = "onelink"
}

variable "repository_name" {
  description = "GitHub repository name"
  default     = "dekaf2"
}

variable "artifact_bucket" {
  description = "S3 Bucket for storing artifacts"
  default     = "artifacts-bucket"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to module resources"
  default     = {}
}

variable "extra_permissions" {
  type        = list
  default     = []
  description = "List of action strings which will be added to IAM service account permissions."
}

variable "image" {
  type = string
  description = "The codebuild image to use"
  #default = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
  #default = "337968609802.dkr.ecr.us-east-1.amazonaws.com/docker-build-base:latest"
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

variable "project_name" {
  type        = string
  description = "Overrides the default repository_name-branch-env naming convention with a user defined project name"
  default     = ""
}

variable "secret_arns" {
  type        = list(string)
  description = "AWS Secrets to allow the project to access"
  default     = []
}

locals {
  final_repository_name = var.project_name != "" ? var.project_name : (var.disable_naming_convention ? var.repository_name : "${var.repository_name}-${var.branch}-${var.env}")
}
