variable "name" {
  type        = string
  description = "A friendly name, server name or FQDN for the resource"
}

variable "project" {
  type        = string
  description = "The project or service this resource belongs (ex: xapis)"
}

variable "environment" {
  type        = string
  description = "The account environment - stage, rc or prod"
}

variable "owner" {
  type        = string
  description = "Email address of team (Distribution List) or individual responsible for the resource"
}

variable "compliance" {
  type        = string
  description = "Data classification (restricted - PII data, non-restricted - Non-PII data)"
}
