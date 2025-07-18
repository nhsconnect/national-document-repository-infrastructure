resource "aws_wafv2_web_acl" "waf_v2_acl" {
  name        = "${terraform.workspace}${var.api ? "-api" : var.cloudfront_acl ? "-cloudfront" : ""}-fw-waf-v2"
  description = "A WAF to secure the Repo application."
  scope       = var.cloudfront_acl ? "CLOUDFRONT" : "REGIONAL"

  default_action {
    allow {}
  }

  # Block an IP if it has attempted to access more than 1000 within 5 minutes
  rule {
    name     = "RateLimit"
    priority = 0

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${terraform.workspace}-waf-v2--RateLimit"
      sampled_requests_enabled   = true
    }
  }

  dynamic "rule" {
    for_each = local.waf_rules_map
    content {
      name     = rule.value["name"]
      priority = rule.key + 1

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value["managed_rule_name"]
          vendor_name = "AWS"


          dynamic "rule_action_override" {
            for_each = rule.value["excluded_rules"]
            content {
              name = excluded_rule.value
              action_to_use {
                allow {}
              }
            }
          }

          dynamic "scope_down_statement" {
            for_each = rule.value["bypass"]
            content {
              not_statement {
                statement {
                  regex_pattern_set_reference_statement {
                    arn = aws_wafv2_regex_pattern_set.exclude_cms_uri.arn

                    field_to_match {
                      uri_path {}
                    }

                    text_transformation {
                      priority = 0
                      type     = "NONE"
                    }
                  }
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value["cloudwatch_metrics_name"]
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${terraform.workspace}-fw-waf_v2"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = "${terraform.workspace}-firewall_waf_v2"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

