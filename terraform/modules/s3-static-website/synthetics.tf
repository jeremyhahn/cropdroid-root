
resource "aws_synthetics_canary" "uptime_canary" {
  name = "website-uptime"
  artifact_s3_location = "s3://${aws_s3_bucket.canaries.id}/"
  execution_role_arn = aws_iam_role.canary_role.arn
  runtime_version = "syn-nodejs-puppeteer-3.5"
  handler = "uptime.handler"
  zip_file = "${path.module}/files/uptime-canary.zip"
  start_canary = true

  success_retention_period = 2
  failure_retention_period = 14

  schedule {
    expression = "rate(1 hour)"
    duration_in_seconds = 0
  }

  run_config {
    timeout_in_seconds = 300
    memory_in_mb = 960
    active_tracing = false
    environment_variables = {
      URL = "https://www.${var.external_dns_name}"
    }
  }

  tags = {
    Name = "uptime-canary"
    Environment = var.env
    Application = "www"
  }
}

resource "aws_cloudwatch_event_rule" "canary_event_rule" {
  name = "canary-rule"
  event_pattern = jsonencode({
    source = ["aws.synthetics"]
    detail = {
      "canary-name": [aws_synthetics_canary.uptime_canary.name],
      "test-run-status": ["FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "canary_event_target" {
  target_id = "UptimeCanaryTarget"
  arn = var.alert_topic_arn
  rule = aws_cloudwatch_event_rule.canary_event_rule.name
}
