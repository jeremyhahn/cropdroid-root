output "artifact_bucket" {
  value = local.artifact_repo
}

output "codebuild_service_role" {
  value = module.pipeline_website.codebuild_service_role
}
