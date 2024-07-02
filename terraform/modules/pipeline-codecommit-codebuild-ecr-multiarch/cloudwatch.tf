
resource "aws_cloudwatch_event_rule" "codecommit" {
  name = "codepipeline-${local.final_project_name}"
  description = "Amazon CloudWatch Events rule to automatically start your pipeline when a change occurs in the AWS CodeCommit source repository and branch. Deleting this may prevent changes from being detected in that pipeline. Read more: http://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-about-starting.html"
  event_pattern = <<PATTERN
{
  "source": [
    "aws.codecommit"
  ],
  "detail-type": [
    "CodeCommit Repository State Change"
  ],
  "resources": [
    "arn:aws:codecommit:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:${var.repository_name}"
  ],
  "detail": {
    "event": [
      "referenceCreated",
      "referenceUpdated"
    ],
    "referenceType": [
      "branch"
    ],
    "referenceName": [
      "master"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "codecommit" {
  rule      = aws_cloudwatch_event_rule.codecommit.name
  role_arn  = aws_iam_role.cwe.arn
  arn       = aws_codepipeline.pipeline.arn
}
