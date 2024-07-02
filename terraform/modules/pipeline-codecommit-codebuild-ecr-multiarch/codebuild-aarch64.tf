data "template_file" "buildspec_aarch64" {
  template = file(var.shared_buildspec ? var.buildspec_template : var.buildspec_aarch64)
  vars = {
    env = var.env
  }
}

resource "aws_codebuild_project" "codebuild_aarch64" {
  name           = "${local.final_project_name}-aarch64"
  badge_enabled  = false
  build_timeout  = 60
  queued_timeout = 480
  service_role   = join("", aws_iam_role.codebuild.*.arn)
  tags           = var.tags

  artifacts {
    encryption_disabled    = false
    name                   = "${local.final_project_name}-aarch64"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = var.codebuild_image_aarch64
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "ARM_CONTAINER"

    environment_variable {
      name  = "ARTIFACT_BUCKET"
      value = var.artifact_bucket
    }

    environment_variable {
      name  = "REPOSITORY_URI"
      value = aws_ecr_repository.service.repository_url
    }

    environment_variable {
      name  = "ASSUME_ROLE_ARN"
      value = aws_iam_role.container_build.arn
    }

    environment_variable {
      name  = "BASE_IMAGE"
      value = var.docker_base_aarch64
    }

    environment_variable {
      name = "IMAGE_TAG"
      value = "aarch64"
    }

    environment_variable {
      name  = "DOCKERHUB_USERNAME"
      value = "${var.dockerhub_secret_name}:username"
      type  = "SECRETS_MANAGER"
    }

    environment_variable {
      name  = "DOCKERHUB_PASSWORD"
      value = "${var.dockerhub_secret_name}:password"
      type  = "SECRETS_MANAGER"
    }

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
    buildspec           = data.template_file.buildspec_aarch64.rendered
    git_clone_depth     = 1
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}
