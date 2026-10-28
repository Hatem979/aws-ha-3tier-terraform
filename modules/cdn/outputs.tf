
output "distribution_id" {
  description = "ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.id
}

output "distribution_arn" {
  description = "ARN of the CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.arn
}

output "distribution_domain_name" {
  description = "Default domain name used to access the application through CloudFront."
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "distribution_hosted_zone_id" {
  description = "Route 53 hosted zone ID associated with the CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.hosted_zone_id
}

output "s3_oac_id" {
  description = "ID of the S3 Origin Access Control."
  value       = aws_cloudfront_origin_access_control.s3.id
}
