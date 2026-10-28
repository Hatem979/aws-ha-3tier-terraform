
output "web_acl_id" {
  description = "ID of the AWS WAF Web ACL."
  value       = aws_wafv2_web_acl.main.id
}

output "web_acl_arn" {
  description = "ARN of the AWS WAF Web ACL to associate with CloudFront."
  value       = aws_wafv2_web_acl.main.arn
}

output "web_acl_name" {
  description = "Name of the AWS WAF Web ACL."
  value       = aws_wafv2_web_acl.main.name
}
