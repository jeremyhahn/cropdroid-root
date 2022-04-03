
module "pipeline_website" {
  source                = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-pipeline-codecommit-codebuild-s3?ref=v0.0.1a"
  env                   = var.env
  region                = var.region
  artifact_bucket       = data.terraform_remote_state.vpc.outputs.s3_artifact_repo
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
    value = data.terraform_remote_state.vpc.outputs.s3_artifact_repo
  }]

  tags = data.terraform_remote_state.shared_bootstrap.outputs.tags
}
