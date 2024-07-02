// Create DNS records that point to CloudFront if enabled
resource "aws_route53_record" "cloudfront_root" {
  count = var.enable_cloudfront ? 1 : 0
  zone_id = var.external_zone_id
  name    = var.external_dns_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.root_s3_distribution[0].domain_name
    zone_id                = aws_cloudfront_distribution.root_s3_distribution[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloudfront_www" {
  count = var.enable_cloudfront ? 1 : 0
  zone_id = var.external_zone_id
  name    = "www.${var.external_dns_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.www_s3_distribution[0].domain_name
    zone_id                = aws_cloudfront_distribution.www_s3_distribution[0].hosted_zone_id
    evaluate_target_health = false
  }
}

// Create DNS records that point to S3 static website if CloudFront disabled
resource "aws_route53_record" "bucket_root" {
  count = var.enable_cloudfront ? 0 : 1
  zone_id = var.external_zone_id
  name    = var.external_dns_name
  type    = "A"

  alias {
    name                   = aws_s3_bucket.root_bucket.website_endpoint
    zone_id                = aws_s3_bucket.root_bucket.hosted_zone_id
    evaluate_target_health = false
  }
}

# resource "aws_route53_record" "www_bucket" {
#   count = var.enable_cloudfront ? 0 : 1
#   zone_id = var.external_zone_id
#   name    = "www.${var.external_dns_name}"
#   type    = "A"
#
#   alias {
#     name                   = aws_s3_bucket.www_bucket.website_endpoint
#     zone_id                = aws_s3_bucket.www_bucket.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

resource "aws_route53_record" "www_bucket" {
  count = var.enable_cloudfront ? 0 : 1
  zone_id = var.external_zone_id
  name    = "www.${var.external_dns_name}"
  type    = "CNAME"
  ttl     = 60
  records = [aws_s3_bucket.www_bucket.website_endpoint]
  #
  # alias {
  #   name                   = aws_s3_bucket.www_bucket.website_endpoint
  #   zone_id                = aws_s3_bucket.www_bucket.hosted_zone_id
  #   evaluate_target_health = false
  # }
}




# Route53 Health Check

// Route 53 metrics are not available if you select any other region than us-east-1

resource "aws_route53_health_check" "http" {
  count             = var.enable_health_checks ? 1 : 0
  fqdn              = "www.${var.external_dns_name}"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"
}

resource "aws_route53_health_check" "https" {
  count             = var.enable_health_checks ? 1 : 0
  fqdn              = "www.${var.external_dns_name}"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"
}

resource "aws_cloudwatch_metric_alarm" "http_alarm" {
  count                     = var.enable_health_checks ? 1 : 0
  alarm_name                = "${var.external_dns_name}-https-alarm-health-check"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "HealthCheckStatus"
  namespace                 = "AWS/Route53"
  period                    = "60"
  statistic                 = "Minimum"
  threshold                 = "1"
  insufficient_data_actions = []
  alarm_actions             = ["${var.alert_topic_arn}"]
  alarm_description         = "Send an alarm if ${var.external_dns_name} HTTP is down"

  dimensions = {
    HealthCheckId = aws_route53_health_check.http[0].id
  }
}

resource "aws_cloudwatch_metric_alarm" "https_alarm" {
  count                     = var.enable_health_checks ? 1 : 0
  alarm_name                = "${var.external_dns_name}-http-alarm-health-check"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "HealthCheckStatus"
  namespace                 = "AWS/Route53"
  period                    = "60"
  statistic                 = "Minimum"
  threshold                 = "1"
  insufficient_data_actions = []
  alarm_actions             = ["${var.alert_topic_arn}"]
  alarm_description         = "Send an alarm if ${var.external_dns_name} HTTPS is down"

  dimensions = {
    HealthCheckId = aws_route53_health_check.https[0].id
  }
}
