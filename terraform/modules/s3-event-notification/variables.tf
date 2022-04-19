variable "name" {
  type        = string
  description = "The lambda name"
  default     = "s3-event-notification"
}

variable "bucket_arn" {
  type        = string
  description = "The ARN of the bucket to watch for events"
}

variable "lambda_filename" {
  type        = string
  description = "The path to the lambda zip archive"
  default     = "files/lambda.zip"
}

variable "lambda_environment_variables" {
  type        = map(string)
  description = "Key/value environment variables for the lambda function"
  default     = {}
}

variable "filter_prefix" {
  type        = string
  description = "(Optional) Object key name prefix."
  default     = ""
}

variable "filter_suffix" {
  type        = string
  description = "(Optional) Object key name suffix."
  default     = ".zip"
}

variable "runtime" {
    type        = string
    description = "The lambda engine runtime"
    default     = "python3.9"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to module resources"
  default     = {}
}

locals {
  notification_arn = var.lambda_environment_variables["NOTIFICATION_ARN"]
  target_bucket    = var.lambda_environment_variables["TARGET_BUCKET"]
  target_key       = var.lambda_environment_variables["TARGET_KEY"]
}
