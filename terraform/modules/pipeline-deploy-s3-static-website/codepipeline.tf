
resource "aws_codepipeline" "pipeline" {
  name     = var.website_bucket
  role_arn = join("", aws_iam_role.codepipeline.*.arn)
  tags     = var.tags

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      run_order        = 1
      version          = 1
      output_artifacts = [
        "SourceArtifact"
      ]
      configuration = {
        S3Bucket             = var.artifact_bucket
        S3ObjectKey          = var.artifact_object_key
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      category = "Build"
      configuration = {
        ProjectName = aws_codebuild_project.codebuild.id
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "BuildArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = 1
    }
  }

  # stage {
  #   name = "Deploy"
  #   action {
  #     name          = "Deploy"
  #     category      = "Deploy"
  #     owner         = "AWS"
  #     provider      = "S3"
  #     run_order     = 1
  #     version       = 1
  #     input_artifacts = [
  #       "SourceArtifact",
  #     ]
  #     output_artifacts = []
  #     configuration = {
  #       BucketName          = var.website_bucket
  #       Extract             = "false"
  #       ObjectKey           = var.artifact_object_key
  #     }
  #   }
  # }
}
