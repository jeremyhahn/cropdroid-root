resource "aws_sns_topic" "alert_email" {
  name = "infrastructure-alerts"

#   policy = <<POLICY
# {
#     "Version":"2012-10-17",
#     "Statement":[{
#         "Effect": "Allow",
#         "Principal": { "Service": "s3.amazonaws.com" },
#         "Action": "SNS:Publish",
#         "Resource": "arn:aws:sns:*:*:infrastructure-alerts"
#     }]
# }
# POLICY
}

resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = aws_sns_topic.alert_email.arn
  protocol  = "email"
  endpoint  = local.infrastructure_alert_email
}
