
resource "aws_iam_role" "codepipeline" {
  name               = "codepipeline-${var.website_name}"
  assume_role_policy = join("", data.aws_iam_policy_document.assume.*.json)
}

data "aws_iam_policy_document" "assume" {

  statement {
    sid = ""

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_policy" "codepipeline" {
  name   = "codepipeline-${var.website_name}"
  policy = join("", data.aws_iam_policy_document.codepipeline.*.json)
}

data "aws_iam_policy_document" "codepipeline" {

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
        "codepipeline.amazonaws.com",
        "ec2.amazonaws.com",
        "s3.amazonaws.com"
      ]
    }
  }

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
    //actions = ["s3:ListBucket"]
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.artifact_bucket}"
    ]
  }

  statement {
    effect = "Allow"
    # actions = [
    #   "s3:GetObject",
    #   "s3:GetObjectVersion",
    #   "s3:GetBucketAcl",
    #   "s3:GetBucketLocation",
    #   "s3:HeadObject"
    # ]
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.artifact_bucket}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.website_bucket}/*",
      "arn:aws:s3:::www.${var.website_bucket}/*"
    ]
  }

}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = aws_iam_role.codepipeline.id
  policy_arn = join("", aws_iam_policy.codepipeline.*.arn)
}
