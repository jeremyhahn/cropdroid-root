# AWS Root Account & Organization

This terraform code is responsible for the root account. This root account plays the role of the "management account" in the [AWS Organizations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_getting-started_concepts.html) hierarchy. For more info, check out the AWS Organizations [introduction](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html) and [best practices](https://aws.amazon.com/organizations/getting-started/best-practices/) as well as best practices on [Organizational Units](https://aws.amazon.com/blogs/mt/best-practices-for-organizational-units-with-aws-organizations/).


# Automation

**DO NOT MANUALLY CREATE RESOURCES IN THE ROOT ACCOUNT!**

The root account is fully managed by Terraform!


# Bootstrapping

The following manual work is required to bootstrap the environment.

### Terraform User

A `terraform` bootstrap IAM user has been manually created as a prerequisite to running the terraform code for the root environment. This user should have the minimum amount of permissions required to create and manage the AWS Organization. A programmatic access key and secret must be generated and configured on the system running this workspace for the first time.

#### AWS Credentials Example

```
[cropdroid-mgmt]
aws_access_key_id = AKIA43UCJ3BDDNABC123
aws_secret_access_key = **********************
```

### Bootstrap User

The root user is not able to switch roles due to how [member account access](https://aws.amazon.com/premiumsupport/knowledge-center/organizations-member-account-access/) works, so a `bootstrap` console user must be created prior to logging into the security account for the first time to provision the credentials for the first IAM (devops) console account.

## Management Account

The management account is the account that you use to create the organization. See the [best practices](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_best-practices_mgmt-acct.html) regarding management and security of this account.

## Member Account

The rest of the accounts that belong to an organization are called member accounts. An account can be a member of only one organization at a time. See the [best practices](https://docs.aws.amazon.com/organizations/latest/userguide/best-practices_member-acct.html) regarding management and security of this account.

## Deleting an Account

https://aws.amazon.com/premiumsupport/knowledge-center/close-aws-account/

https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html#orgs_manage_accounts_access-as-root

https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_close.html
