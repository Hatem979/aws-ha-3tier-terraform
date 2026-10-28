
output "bucket_id" {
  description = "Name of the S3 bucket."
  value       = aws_s3_bucket.files.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.files.arn
}

output "bucket_regional_domain_name" {
  description = "Regional DNS domain name of the S3 bucket."
  value       = aws_s3_bucket.files.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "Route 53 hosted zone ID associated with the S3 bucket endpoint."
  value       = aws_s3_bucket.files.hosted_zone_id
}
