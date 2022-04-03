variable "env" {
  type        = string
  description = "Application environment (ie. staging, rc, prod)"
  default     = "staging"
}

variable "profile" {
  type        = string
  description = "Name of AWS credentials profile context to use for authentication"
  default     = "staging"
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "The name of the bucket without the www. prefix. Normally domain_name."
  default     = "example-website"
}

variable "external_zone_id" {
  type        = string
  description = "The external zone id to create A records for the s3 static website"
}

variable "external_dns_name" {
  type        = string
  description = "The external zone name to create A records for the s3 static website"
  default     = "example-website"
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "The ACM certificate SANs names to add to the generated certificate"
  default     = []
}

variable "tags" {
  type        = map
  description = "Tags to assign created resources"
  default     = {}
}

variable "enable_cloudfront" {
  type        = bool
  description = "True to enable CloudFront CDN distribution for the website"
  default     = false
}

variable "pipeline_role_arn" {
  type        = string
  description = "The codebuild deployment pipeline ARN that deploys the website to the s3 bucket"
}

variable "website_index_document" {
  description = "Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders.  Defaults to index.html"
  type        = string
  default     = "index.html"
}

variable "website_error_document" {
  description = "(Optional) An absolute path to the document to return in case of a 4XX error. Defaults to 404.html"
  type        = string
  default     = "404.html"
}

variable "alert_topic_arn" {
  description = "The SNS topic ARN used for cloudwatch alerts"
  type        = string
}

variable "enable_health_checks" {
  description = "Turn Route 53 health checks on/off"
  type        = bool
  default     = true
}

variable "enable_waf" {
  type        = bool
  description = "Turn Web Application Firewall (WAF) on/off"
  default     = false
}

locals {
  redirect_protocol = var.enable_cloudfront ? "https" : "http"
  web_acl_id = var.enable_waf ? aws_wafv2_web_acl.www[0].arn : ""
}
