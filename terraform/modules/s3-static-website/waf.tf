resource "aws_wafv2_web_acl" "www" {
  count    = var.enable_waf ? 1 : 0
  name     = "my-acl"
  scope    = "CLOUDFRONT"

  default_action {
    block {}
  }

  rule {
    name     = "acl-rule"
    priority = 1
    override_action {
      none {}
    }
    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.www[0].arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "acl-rule-metric"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "acl-metric"
    sampled_requests_enabled   = false
  }

  tags = var.tags
}

resource "aws_wafv2_rule_group" "www" {
  count    = var.enable_waf ? 1 : 0
  name     = "us-traffic-only-rule"
  scope    = "CLOUDFRONT"
  capacity = 2

  rule {
    name     = "rule-1"
    priority = 1

    action {
      allow {}
    }

    statement {

      geo_match_statement {
        country_codes = ["US"]
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "rule-visibility-config"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "visibility-config"
    sampled_requests_enabled   = false
  }
}
