resource "aws_codecommit_repository" "tf_module_bastion" {
  repository_name = "tf-module-bastion"
}

resource "aws_codecommit_repository" "tf_module_ecs" {
  repository_name = "tf-module-ecs"
}

resource "aws_codecommit_repository" "tf_module_pipeline_codecommit_codebuild" {
  repository_name = "tf-module-pipeline-codecommit-codebuild"
}

resource "aws_codecommit_repository" "tf_module_pipeline_codecommit_codebuild_ecr" {
  repository_name = "tf-module-pipeline-codecommit-codebuild-ecr"
}

resource "aws_codecommit_repository" "tf_module_pipeline_codecommit_codebuild_ecr_multiarch" {
  repository_name = "tf-module-pipeline-codecommit-codebuild-ecr-multiarch"
}

resource "aws_codecommit_repository" "tf_module_pipeline_codecommit_codebuild_s3" {
  repository_name = "tf-module-pipeline-codecommit-codebuild-s3"
}

resource "aws_codecommit_repository" "tf_module_pipeline_codecommit_codebuild_s3_multiarch" {
  repository_name = "tf-module-pipeline-codecommit-codebuild-s3-multiarch"
}

resource "aws_codecommit_repository" "tf_module_pipeline_deploy_s3_static_website" {
  repository_name = "tf-module-pipeline-deploy-s3-static-website"
}

resource "aws_codecommit_repository" "tf_module_pipeline_github_codebuild_s3" {
  repository_name = "tf-module-pipeline-github-codebuild-s3"
}

resource "aws_codecommit_repository" "tf_module_pipeline_github_codebuild_s3_multiarch" {
  repository_name = "tf-module-pipeline-github-codebuild-s3-multiarch"
}

resource "aws_codecommit_repository" "tf_module_remotestate" {
  repository_name = "tf-module-remotestate"
}

resource "aws_codecommit_repository" "tf_module_s3bucket" {
  repository_name = "tf-module-s3bucket"
}

resource "aws_codecommit_repository" "tf_module_s3_static_website" {
  repository_name = "tf-module-s3-static-website"
}

resource "aws_codecommit_repository" "tf_module_tagging" {
  repository_name = "tf-module-tagging"
}

resource "aws_codecommit_repository" "tf_module_vpc" {
  repository_name = "tf-module-vpc"
}
