locals {
  # required by USA-based CI pipeline runners to run smoke tests
  allow_us_comms = contains(["ndr-dev"], terraform.workspace)
}

resource "aws_cloudfront_origin_access_control" "cloudfront_s3_oac" {
  name                              = "${terraform.workspace}_cloudfront_s3_oac_policy"
  description                       = "Cloud Front S3 OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "never"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "distribution" {
  count       = var.has_secondary_bucket ? 0 : 1
  price_class = "PriceClass_100"

  origin {
    domain_name              = var.bucket_domain_name
    origin_id                = var.bucket_id
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
  }
  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods          = ["HEAD", "GET", "OPTIONS"]
    cached_methods           = ["HEAD", "GET", "OPTIONS"]
    target_origin_id         = var.bucket_id
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = aws_cloudfront_cache_policy.nocache.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.viewer_policy.id

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = var.qualifed_arn
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = local.allow_us_comms ? ["GB", "US"] : ["GB"]
    }
  }
  web_acl_id = var.web_acl_id
}

resource "aws_cloudfront_distribution" "distribution_with_secondary_bucket" {
  count           = var.has_secondary_bucket ? 1 : 0
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  origin {
    domain_name              = var.bucket_domain_name
    origin_id                = var.bucket_id
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
  }

  default_cache_behavior {
    allowed_methods          = ["HEAD", "GET", "OPTIONS"]
    cached_methods           = ["HEAD", "GET", "OPTIONS"]
    target_origin_id         = var.bucket_id
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = aws_cloudfront_cache_policy.nocache.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.viewer_policy.id

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = var.qualifed_arn
    }
  }

  origin {
    domain_name              = var.secondary_bucket_domain_name
    origin_id                = var.secondary_bucket_id
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
  }

  ordered_cache_behavior {
    allowed_methods          = ["HEAD", "GET", "OPTIONS"]
    cached_methods           = ["HEAD", "GET", "OPTIONS"]
    path_pattern             = var.secondary_bucket_path_pattern
    target_origin_id         = var.secondary_bucket_id
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = aws_cloudfront_cache_policy.nocache.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.viewer_policy.id

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = var.qualifed_arn
    }

  }

  dynamic "logging_config" {
    for_each = var.log_bucket_id != "" ? [1] : []
    content {
      bucket = var.log_bucket_id
      # this might break it as path pattern is in format /pattern/
      prefix = var.secondary_bucket_path_pattern
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = local.allow_us_comms ? ["GB", "US"] : ["GB"]
    }
  }
  web_acl_id = var.web_acl_id

}


resource "aws_cloudfront_origin_request_policy" "viewer_policy" {
  name = "${terraform.workspace}_BlockQueriesAndAllowViewer"

  query_strings_config {
    query_string_behavior = "whitelist"
    query_strings {
      items = [
        "X-Amz-Algorithm",
        "X-Amz-Credential",
        "X-Amz-Date",
        "X-Amz-Expires",
        "X-Amz-SignedHeaders",
        "X-Amz-Signature",
        "X-Amz-Security-Token"
      ]
    }
  }


  headers_config {
    header_behavior = "whitelist"
    headers {
      items = [
        "Host",
        "CloudFront-Viewer-Country",
        "X-Forwarded-For"
      ]
    }
  }

  cookies_config {
    cookie_behavior = "none"
  }
}

resource "aws_cloudfront_cache_policy" "nocache" {
  name        = "${terraform.workspace}_nocache_policy"
  default_ttl = 0
  max_ttl     = 0
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}
