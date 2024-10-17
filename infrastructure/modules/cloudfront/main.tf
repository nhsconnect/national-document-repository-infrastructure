resource "aws_cloudfront_origin_access_control" "cloudfront_s3_oac" {
  name                              = "${terraform.workspace}_cloudfront_s3_oac_policy"
  description                       = "Cloud Front S3 OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "never"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "distribution" {
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
    origin_request_policy_id = var.forwarding_policy

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = var.qualifed_arn
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "whitelist" # Restrict access to only the listed countries
      locations        = ["GB"]      # ISO code for the United Kingdom
    }
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