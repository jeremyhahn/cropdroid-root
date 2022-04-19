resource "aws_s3_bucket_policy" "remote_state" {

  bucket = module.remotestate.bucket

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "SharedRemoteStatePolicy",
  "Statement": [
    {
      "Sid": "RootAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${data.terraform_remote_state.root_bootstrap.outputs.ct_management_account_id}:root"
        ]
      },
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${module.remotestate.bucket}",
        "arn:aws:s3:::${module.remotestate.bucket}/*"
      ]
    },
    {
      "Sid": "ListBucketAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${local.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_da9b8a59c2483c73",
          "arn:aws:iam::${local.account_id}:assumed-role/AWSReservedSSO_AWSAdministratorAccess_da9b8a59c2483c73/aws+shared@${local.sso_domain}",
          "arn:aws:iam::${local.staging_account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_a3f315f0e7cc692a",
          "arn:aws:sts::${local.staging_account_id}:assumed-role/AWSReservedSSO_AWSAdministratorAccess_a3f315f0e7cc692a/aws+staging@${local.sso_domain}",
          "arn:aws:iam::${local.prod_account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_746a31ddf0c5ed5c",
          "arn:aws:iam::${local.prod_account_id}:assumed-role/AWSReservedSSO_AWSAdministratorAccess_746a31ddf0c5ed5c/aws+prod@${local.sso_domain}"
        ]
      },
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": "arn:aws:s3:::${module.remotestate.bucket}"
    },
    {
      "Sid": "SharedObjectsAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${local.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_da9b8a59c2483c73",
          "arn:aws:iam::${local.account_id}:assumed-role/AWSReservedSSO_AWSAdministratorAccess_da9b8a59c2483c73/aws+shared@${local.sso_domain}"
        ]
      },
      "Action": [
        "s3:Get*",
        "S3:Put*",
        "s3:List*"
      ],
      "Resource": "arn:aws:s3:::${module.remotestate.bucket}/shared/*"
    },
    {
      "Sid": "SharedObjectsReadOnlyAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${local.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_da9b8a59c2483c73",
          "arn:aws:iam::${local.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSOrganizationsFullAccess_c4029ba22c8daeab",
          "arn:aws:iam::${local.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSPowerUserAccess_25c53df32a1253e2",
          "arn:aws:iam::${local.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSReadOnlyAccess_36f8fb192bf92169",
          "arn:aws:iam::${local.staging_account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_a3f315f0e7cc692a",
          "arn:aws:iam::${local.staging_account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSOrganizationsFullAccess_9ba3758f193ef8e1",
          "arn:aws:iam::${local.staging_account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSPowerUserAccess_6b2f6d06beb058b7",
          "arn:aws:iam::${local.staging_account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSReadOnlyAccess_9ef77f738096cab9",
          "arn:aws:sts::${local.staging_account_id}:assumed-role/AWSReservedSSO_AWSAdministratorAccess_a3f315f0e7cc692a/aws+staging@${local.sso_domain}",
          "arn:aws:iam::${local.prod_account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_746a31ddf0c5ed5c",
          "arn:aws:iam::${local.prod_account_id}:assumed-role/AWSReservedSSO_AWSAdministratorAccess_746a31ddf0c5ed5c/aws+prod@${local.sso_domain}"
        ]
      },
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": "arn:aws:s3:::${module.remotestate.bucket}/shared/*"
    },
    {
      "Sid": "SharedReadOnlyObjectsAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${local.staging_account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_a3f315f0e7cc692a",
          "arn:aws:sts::${local.staging_account_id}:assumed-role/AWSReservedSSO_AWSAdministratorAccess_a3f315f0e7cc692a/aws+staging@${local.sso_domain}"
        ]
      },
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": [
        "arn:aws:s3:::${module.remotestate.bucket}/staging/vpc.tfstate",
        "arn:aws:s3:::${module.remotestate.bucket}/prod/vpc.tfstate"
      ]
    },
    {
      "Sid": "StageObjectsAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${local.staging_account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_a3f315f0e7cc692a",
          "arn:aws:sts::${local.staging_account_id}:assumed-role/AWSReservedSSO_AWSAdministratorAccess_a3f315f0e7cc692a/aws+staging@${local.sso_domain}"
        ]
      },
      "Action": [
        "s3:Get*",
        "s3:Put*",
        "s3:List*"
      ],
      "Resource": [
        "arn:aws:s3:::${module.remotestate.bucket}/staging*",
        "arn:aws:s3:::${module.remotestate.bucket}/staging/*"
      ]
    },
    {
      "Sid": "ProdObjectsAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${local.prod_account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_746a31ddf0c5ed5c",
          "arn:aws:iam::${local.prod_account_id}:assumed-role/AWSReservedSSO_AWSAdministratorAccess_746a31ddf0c5ed5c/aws+prod@${local.sso_domain}"
        ]
      },
      "Action": [
        "s3:Get*",
        "s3:Put*",
        "s3:List*"
      ],
      "Resource": [
        "arn:aws:s3:::${module.remotestate.bucket}/prod*",
        "arn:aws:s3:::${module.remotestate.bucket}/prod/*"
      ]
    }
  ]
}
POLICY
}
