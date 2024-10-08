output "cloudfront_url" {
  value = aws_cloudfront_distribution.distribution.domain_name
}

output "cloudfront_arn" {
  description = "The ARN of the CloudFront Distribution"
  value       = aws_cloudfront_distribution.distribution.arn
}