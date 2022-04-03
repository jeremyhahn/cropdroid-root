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
  default     = "docker-base"
}

variable "project_name" {
  type        = string
  description = "User defined name for the pipeline project"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to module resources"
  default     = {}
}

variable "artifact_bucket" {
  description = "S3 Bucket for storing artifacts"
  default     = "artifacts-bucket"
}

variable "extra_permissions" {
  type        = list
  default     = []
  description = "List of action strings which will be added to IAM service account permissions."
}

variable "codebuild_image" {
  type = string
  description = "The codebuild runtime environment used to run the project"
  default = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

variable "codebuild_compute" {
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
  description = "A supported codebuild compute environment. https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html"
}

variable "docker_base" {
  type        = string
  description = "The base image used to build the ECR docker image"
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
  description = "A list of maps, that contain both the key 'name' and the key 'value' to be used as additional environment variables for the build"
}

variable "container_assume_role_identifiers" {
  type        = list(string)
  default     = []
  description = "Assume role policy identifiers for the container build role"
}

variable "container_build_role_trusted_entities" {
  type        = list(string)
  description = "List of roles to configure as trusted entities on the IAM role assumed by docker while building the container"
  default     = [] #["codebuild.amazonaws.com"]
}

variable "image_scanning" {
  type        = bool
  description = "Amazon ECR uses the Common Vulnerabilities and Exposures (CVEs) database from the open-source Clair project and provides a list of scan findings."
  default     = false
}

variable "buildspec_template" {
  type        = string
  description = "The file path to the codebuild buildspec file"
  default     = "files/buildspec.yml"
}

variable "ecr_allowed_principals" {
  type        = list(string)
  description = "List of AWS principals allowed to access the ECR repository"
  default     = ["*"]
}

variable "disable_naming_convention" {
  type        = bool
  description = "Disables appending branch and environment to repository name"
  default     = false
}

variable "dockerhub_secret_arn" {
  type        = string
  description = "AWS Secrets Manager ARN that stores hub.docker.com credentials"
  default     = "arn:aws:secretsmanager:us-east-1:195741991018:secret:/codebuild/dockerhub-VuowDp"
}

locals {
  final_project_name = var.project_name != "" ? (var.disable_naming_convention ? var.project_name : "${var.project_name}-${var.branch}-${var.env}") : "${var.repository_name}-${var.branch}-${var.env}"
}
