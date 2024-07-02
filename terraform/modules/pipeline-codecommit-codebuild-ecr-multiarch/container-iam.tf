
resource "aws_iam_role" "container_build" {
  name                  = "container-${local.final_project_name}"
  assume_role_policy    = data.aws_iam_policy_document.container_build_role.json
  force_detach_policies = true
}

resource "aws_iam_policy" "container_build" {
  name   = "container-${local.final_project_name}"
  path   = "/container-role/"
  policy = data.aws_iam_policy_document.container_build.json
}

data "aws_iam_policy_document" "container_build_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "AWS"
      identifiers = concat(
        [aws_iam_role.codebuild.arn],
        var.container_build_role_trusted_entities
      )
    }
  }
}

data "aws_iam_policy_document" "container_build" {

  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
    condition {
      test = "StringEqualsIfExists"
      variable = "iam:PassedToService"
      values = [
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:HeadObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.artifact_bucket}",
      "arn:aws:s3:::${var.artifact_bucket}/*"
    ]
  }

  # statement {
  #   effect = "Allow"
  #   actions = [
  #     "elasticbeanstalk:*",
  #     "ec2:*",
  #     "elasticloadbalancing:*",
  #     "autoscaling:*",
  #     "cloudwatch:*",
  #     "s3:*",
  #     "sns:*",
  #     "cloudformation:*",
  #     "rds:*",
  #     "sqs:*",
  #     "ecs:*"
  #   ]
  #   resources = ["*"]
  # }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:PutImage"
    ]
    resources = ["*"]
  }

}

resource "aws_iam_role_policy_attachment" "container_build" {
  role       = aws_iam_role.container_build.id
  policy_arn = join("", aws_iam_policy.container_build.*.arn)
}
