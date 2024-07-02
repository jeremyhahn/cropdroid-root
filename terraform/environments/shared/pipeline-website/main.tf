
module "pipeline_website" {
  source                = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-pipeline-codecommit-codebuild-s3?ref=v0.0.1a"
  env                   = var.env
  region                = var.region
  artifact_bucket       = local.artifact_repo
  buildspec_template    = file("files/buildspec.yml")

  repository_name       = "service-website"
  branch                = "master"
  owner                 = "jeremyhahn"

  # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
  # https://aws.amazon.com/codebuild/pricing/
  codebuild_image            = "aws/codebuild/amazonlinux2-aarch64-standard:2.0"
  codebuild_compute          = "BUILD_GENERAL1_SMALL"   # $0.0034 / min
  codebuild_environment_type = "ARM_CONTAINER"

  environment_variables = [{
    name  = "ARTIFACT_BUCKET"
    value = local.artifact_repo
  }]

  tags = local.tags
}

module "website_s3_event_notification" {
  source = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-s3-event-notification?ref=v0.0.1a"
  name   = "website-archive-changed-notification"
  tags   = local.tags

  bucket_arn = local.lambda_bucket_arn
  lambda_filename = local.lambda_filename

  lambda_environment_variables = local.lambda_env_vars
}
