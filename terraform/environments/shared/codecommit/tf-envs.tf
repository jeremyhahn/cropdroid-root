resource "aws_codecommit_repository" "tf_env_root" {
  repository_name = "tf-env-root"
}

resource "aws_codecommit_repository" "tf_env_shared" {
  repository_name = "tf-env-shared"
}

resource "aws_codecommit_repository" "tf_env_staging" {
  repository_name = "tf-env-staging"
}
