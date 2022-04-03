# Standard tagging module

This module provides a common set of tags useful for resource groups, cost allocation, automation, operations support, access control and security risk management in alignment with [AWS Tagging Best Practices](https://d1.awsstatic.com/whitepapers/aws-tagging-best-practices.pdf).


## Usage

Not all tags are required, but all are exposed via the "tags" map.

```
module "tagging" {
  source = "../"
  name        = "Test-Name"
  project     = "Test-Project"
  environment = "Test-Environment"
  owner       = "Test-Owner"
  compliance  = "Test-Compliance"
}

resource "some_aws_resource" "foo" {
	... resource config here ...

  tags = "${merge(
    local.tags,
    module.tagging.tags,
    map("name", "Foobar")
  )}"
}
```


## Examples

```
module "tagging" {
  source = "../"
  name        = "Test-Name"
  project     = "Test-Project"
  environment = "Test-Environment"
  owner       = "Test-Owner"
  compliance  = "Test-Compliance"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | Server name or FQDN | string | `` | yes |
| project | tbd in RFC-0026 | string | `` | yes |
| environment | Prod, staging, integration, QA or development | string | `` | yes |
| owner | Email address of team (Distribution List) | string | `` | yes |
| compliance | Data classification (restricted - PII data, non-restricted - Non-PII data) | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| tags | Mapping of tags for common AWS resources |
| tags\_as\_list | Used for things that need it in format of [{key=... value=... propagate_at_launch=...},{...}] |
