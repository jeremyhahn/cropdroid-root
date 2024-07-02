resource "aws_codepipeline" "pipeline" {
  name     = local.final_project_name
  role_arn = join("", aws_iam_role.codepipeline.*.arn)
  tags     = var.tags

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name          = "Source"
      category      = "Source"
      provider      = "CodeCommit"
      owner         = "AWS"
      run_order     = 1
      version       = 1

      input_artifacts  = []

      output_artifacts = [
        "SourceArtifact",
      ]

      configuration = {
        BranchName           = var.branch
        RepositoryName       = var.repository_name
        PollForSourceChanges = "false"
      }

    }
  }

  stage {
    name = "Build"

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
      version   = "1"
    }
  }

}
