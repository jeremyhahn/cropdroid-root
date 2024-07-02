resource "aws_sns_topic" "alert_email" {
  name = "infrastructure-alerts"
}

resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = aws_sns_topic.alert_email.arn
  protocol  = "email"
  endpoint  = local.infrastructure_alert_email
}
