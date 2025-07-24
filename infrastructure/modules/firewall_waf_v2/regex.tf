resource "aws_wafv2_regex_pattern_set" "large_body_uri" {
  name        = "${terraform.workspace}-fw-waf-body-size${var.api ? "-api" : ""}"
  description = "A set of regex to allow specific pages to bypass the large body check"
  scope       = var.cloudfront_acl ? "CLOUDFRONT" : "REGIONAL"

  # Allow pages involving images
  regular_expression {
    regex_string = local.image_regex
  }

  # Allow pages involving content
  regular_expression {
    regex_string = "^\\/pages{1}\\/((\\d+\\/edit)|(add\\/(\\w+\\/)+\\d+)){1}\\/$"
  }

  tags = {
    Name = "${terraform.workspace}-fw-waf-body-size"
  }
}

resource "aws_wafv2_regex_pattern_set" "xss_body_uri" {
  name        = "${terraform.workspace}-fw-waf-body-xss${var.api ? "-api" : ""}"
  description = "A regex to allow specific pages to bypass XSS checks on body"
  scope       = var.cloudfront_acl ? "CLOUDFRONT" : "REGIONAL"

  # Allow pages involving images
  regular_expression {
    regex_string = local.image_regex
  }

  tags = {
    Name = "${terraform.workspace}-fw-waf-body-xss"
  }
}

resource "aws_wafv2_regex_pattern_set" "exclude_cms_uri" {
  name        = "${terraform.workspace}-fw-waf-cms-exclude${var.api ? "-api" : ""}"
  description = "A regex to allow CMS calls to bypass firewalls"
  scope       = var.cloudfront_acl ? "CLOUDFRONT" : "REGIONAL"

  # Allow pages involving images
  regular_expression {
    regex_string = "^\\/choose-external-link\\/.*$"
  }

  tags = {
    Name = "${terraform.workspace}-fw-waf-cms-exclude"
  }
}
