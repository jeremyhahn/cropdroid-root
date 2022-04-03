output "artifact_bucket" {
  value = data.terraform_remote_state.vpc.outputs.s3_artifact_repo
}

output "codebuild_service_role" {
  value = module.pipeline_website.codebuild_service_role
}
