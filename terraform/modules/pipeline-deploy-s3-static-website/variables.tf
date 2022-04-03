variable "env" {
  type        = string
  description = "Deployment environment"
  default     = "staging"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to module resources"
  default     = {}
}

variable "website_name" {
  type        = string
  description = "The name of the website"
}

variable "artifact_bucket" {
  type        = string
  description = "The S3 bucket that stores the built website artifact"
}

variable "artifact_object_key" {
  type        = string
  description = "The relative path to the website artifact in source_bucket"
}

variable "website_bucket" {
  type        = string
  description = "The S3 bucket that hosts the static website"
}

variable "buildspec_template" {
  type        = string
  description = "The file path to the codebuild buildspec file"
}

variable "image" {
  type = string
  description = "The codebuild image to use"
  default = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
  #default = "337968609802.dkr.ecr.us-east-1.amazonaws.com/docker-build-base:latest"
}

variable "codebuild_compute" {
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
  description = "A supported codebuild compute environment. https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html"
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
  description = "A list of maps, that contain both the key 'name' and the key 'value' to be used as additional environment variables for the build"
}
