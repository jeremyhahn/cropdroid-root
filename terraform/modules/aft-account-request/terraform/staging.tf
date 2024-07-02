module "staging" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "aws+staging@cropdroid.com"
    AccountName               = "staging"
    ManagedOrganizationalUnit = "Staging"
    SSOUserEmail              = "aws+staging@cropdroid.com"
    SSOUserFirstName          = "Staging"
    SSOUserLastName           = "AFT"
  }

  account_tags = {
    "AFT" = true
  }

  change_management_parameters = {
    change_requested_by = "Jeremy Hahn"
    change_reason       = "AWS Control Tower Account Factory for Terraform"
  }

  custom_fields = {
    group = "non-prod"
  }

  account_customizations_name = "staging"
}
