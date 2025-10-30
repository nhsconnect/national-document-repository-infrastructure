output "cloudfront_url" {
  value = var.has_secondary_bucket ? aws_cloudfront_distribution.distribution_with_secondary_bucket[0].domain_name : aws_cloudfront_distribution.distribution[0].domain_name
}

output "cloudfront_arn" {
  description = "The ARN of the CloudFront Distribution"
  value       = var.has_secondary_bucket ? aws_cloudfront_distribution.distribution_with_secondary_bucket[0].arn : aws_cloudfront_distribution.distribution[0].arn
}