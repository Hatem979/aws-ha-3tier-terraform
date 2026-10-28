
output "vpc_id" {
  description = "ID of the project VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs"
  value       = module.network.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Private database subnet IDs"
  value       = module.network.private_db_subnet_ids
}


output "alb_security_group_id" {
  value = module.security.alb_security_group_id
}

output "app_security_group_id" {
  value = module.security.app_security_group_id
}

output "database_security_group_id" {
  value = module.security.database_security_group_id
}
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "target_group_arn" {
  description = "ARN of the application Target Group"
  value       = module.alb.target_group_arn
}
output "launch_template_id" {
  description = "Application Launch Template ID"
  value       = module.compute.launch_template_id
}

output "autoscaling_group_name" {
  description = "Application Auto Scaling Group name"
  value       = module.compute.autoscaling_group_name
}

output "database_endpoint" {
  description = "RDS database endpoint"
  value       = module.database.db_endpoint
}

output "database_name" {
  description = "Initial database name"
  value       = module.database.db_name
}

output "database_port" {
  description = "RDS database port"
  value       = module.database.db_port
}

output "database_secret_arn" {
  description = "ARN of the RDS-managed master user secret"
  value       = module.database.master_user_secret_arn
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.monitoring.cloudwatch_dashboard_name
}

output "monitoring_sns_topic_arn" {
  description = "SNS topic ARN for monitoring alerts"
  value       = module.monitoring.sns_topic_arn
}


output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID."
  value       = module.cdn.distribution_id
}

output "cloudfront_domain_name" {
  description = "Public CloudFront domain name for accessing the application."
  value       = module.cdn.distribution_domain_name
}

output "waf_web_acl_arn" {
  description = "ARN of the Web ACL protecting the CloudFront distribution."
  value       = module.waf.web_acl_arn
}
