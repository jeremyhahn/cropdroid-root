resource "aws_codepipeline" "pipeline" {
  name     = local.final_repository_name
  role_arn = join("", aws_iam_role.codepipeline.*.arn)
  tags     = var.tags

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      provider = "CodeStarSourceConnection"
      owner    = "AWS"
      configuration = {
        BranchName           = var.branch
        FullRepositoryId     = "${var.github_org}/${var.repository_name}"
        ConnectionArn        = var.codestar_connection_arn
        OutputArtifactFormat = "CODE_ZIP"
      }
      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact",
      ]
      run_order = 1
      version   = 1
    }
  }

  stage {
    name = "Build"

    action {
      name     = "x86"
      category = "Build"
      configuration = {
        ProjectName = aws_codebuild_project.codebuild.id
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      output_artifacts = [
        "BuildArtifact-x86",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
    }

    action {
      name     = "aarch64"
      category = "Build"
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_aarch64.id
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      output_artifacts = [
        "BuildArtifact-aarch64",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
    }

  }

  stage {
    name = "Package"

    action {
      name      = "x86"
      category  = "Deploy"
      owner     = "AWS"
      provider  = "S3"
      run_order = 1
      version   = 1

      input_artifacts = [
        "BuildArtifact-x86"
      ]

      output_artifacts = []

      configuration = {
        BucketName = var.artifact_bucket
        Extract    = "false",
        ObjectKey  = "${var.repository_name}.zip"
        #KMSEncryptionKeyARN = "arn:aws:kms:${var.region}:${data.aws_caller_identity.default.account_id}:aws/s3"
      }
    }

    action {
      name      = "aarch64"
      category  = "Deploy"
      owner     = "AWS"
      provider  = "S3"
      run_order = 1
      version   = 1

      input_artifacts = [
        "BuildArtifact-aarch64"
      ]

      output_artifacts = []

      configuration = {
        BucketName = var.artifact_bucket
        Extract    = "false",
        ObjectKey  = "${var.repository_name}-aarch64.zip"
        #KMSEncryptionKeyARN = "arn:aws:kms:${var.region}:${data.aws_caller_identity.default.account_id}:aws/s3"
      }
    }
  }

}
