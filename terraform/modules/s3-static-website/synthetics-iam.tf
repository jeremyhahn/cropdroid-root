data "aws_iam_policy_document" "canary_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "canary_role" {
  count = var.enable_synthetics ? 1 : 0

  name               = "canary-role"
  path               = "/www/"
  assume_role_policy = data.aws_iam_policy_document.canary_assume_role_policy.json
  description        = "IAM role for AWS Synthetic Monitoring Canaries"
}

data "aws_iam_policy_document" "canary_policy" {
  statement {
    sid     = "CanaryGeneric"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "cloudwatch:PutMetricData",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "canary_policy" {
  count = var.enable_synthetics ? 1 : 0

  name        = "canary-policy"
  path        = "/www/"
  policy      = data.aws_iam_policy_document.canary_policy.json
  description = "IAM role for AWS Synthetic Monitoring Canaries"
}

resource "aws_iam_role_policy_attachment" "canary_policy_attachment" {
  count = var.enable_synthetics ? 1 : 0

  role       = aws_iam_role.canary_role[0].name
  policy_arn = aws_iam_policy.canary_policy[0].arn
}
