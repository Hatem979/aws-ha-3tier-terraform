
output "alb_security_group_id" {
  description = "Security Group ID for the Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security Group ID for application resources"
  value       = aws_security_group.private_app.id
}

output "database_security_group_id" {
  description = "Security Group ID for database resources"
  value       = aws_security_group.private_db.id
}
