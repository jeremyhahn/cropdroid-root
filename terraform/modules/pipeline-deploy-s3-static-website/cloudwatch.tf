
resource "aws_cloudwatch_event_rule" "static_website" {
  name = "codepipeline-${var.website_name}"
  description = "Amazon CloudWatch Events rule to automatically start your pipeline when a change occurs in the AWS CodeCommit source repository and branch. Deleting this may prevent changes from being detected in that pipeline. Read more: http://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-about-starting.html"
  event_pattern = <<PATTERN
{
  "source": [
    "aws.s3"
  ],
  "detail-type": [
    "Static website source change event"
  ],
  "resources": [
    "arn:aws:codecommit:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:${var.artifact_bucket}/${var.artifact_object_key}"
  ],
  "detail": {
    "eventSource": [
      "s3.amazonaws.com"
    ],
    "eventName": [
      "CopyObject",
      "CompleteMultipartUpload",
      "PutObject"
    ],
    "requestParameters": {
      "bucketName": [
        "${var.artifact_bucket}"
      ],
      "key": [
        "${var.artifact_object_key}"
      ]
    }
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "codecommit" {
  rule      = aws_cloudwatch_event_rule.static_website.name
  role_arn  = aws_iam_role.cwe.arn
  arn       = aws_codepipeline.pipeline.arn
}
