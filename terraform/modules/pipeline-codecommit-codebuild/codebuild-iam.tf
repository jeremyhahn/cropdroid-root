resource "aws_iam_role" "codebuild" {
  name                  = "codebuild-${local.final_repository_name}"
  assume_role_policy    = data.aws_iam_policy_document.role.json
  force_detach_policies = true
}

data "aws_iam_policy_document" "role" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_policy" "codebuild" {
  name   = "codebuild-${local.final_repository_name}"
  path   = "/service-role/"
  policy = data.aws_iam_policy_document.codebuild.json
}

data "aws_iam_policy_document" "codebuild" {

  statement {
    sid = "CodeBuildDefaultPolicy"
    effect = "Allow"
    actions = [
      "codebuild:*",
      "iam:PassRole"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:*"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:*"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["s3:*"]
    #actions = [
    #  "s3:PutObject",
    #  "s3:GetObject",
    #  "s3:GetObjectVersion",
    #  "s3:GetBucketAcl",
    #  "s3:GetBucketLocation",
    #]
    resources = [
      "arn:aws:s3:::${var.artifact_bucket}",
      "arn:aws:s3:::${var.artifact_bucket}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:us-east-1:${data.aws_caller_identity.default.account_id}:log-group:/aws/codebuild/${local.final_repository_name}",
      "arn:aws:logs:us-east-1:${data.aws_caller_identity.default.account_id}:log-group:/aws/codebuild/${local.final_repository_name}:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages"
    ]
    resources = [
      "arn:aws:codebuild:us-east-1:337968609802:report-group/${var.repository_name}-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = var.secret_arns
  }

}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codebuild.id
  policy_arn = join("", aws_iam_policy.codebuild.*.arn)
}
