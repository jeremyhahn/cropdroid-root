
resource "aws_codebuild_project" "codebuild_aarch64" {
  name           = "${local.final_repository_name}-aarch64"
  badge_enabled  = false
  build_timeout  = 60
  queued_timeout = 480
  service_role   = join("", aws_iam_role.codebuild.*.arn)
  tags           = var.tags

  artifacts {
    encryption_disabled    = false
    name                   = var.repository_name
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = var.codebuild_image != "" ? var.codebuild_image : var.codebuild_image_aarch64
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "ARM_CONTAINER"

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = data.template_file.buildspec.rendered
    git_clone_depth     = 1
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}
