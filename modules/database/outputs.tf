output "db_instance_id" {
  description = "RDS DB instance identifier"
  value       = aws_db_instance.database.id
}

output "db_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.database.endpoint
}

output "db_address" {
  description = "RDS database hostname"
  value       = aws_db_instance.database.address
}

output "db_port" {
  description = "RDS database port"
  value       = aws_db_instance.database.port
}

output "db_name" {
  description = "Initial database name"
  value       = aws_db_instance.database.db_name
}

output "db_subnet_group_name" {
  description = "RDS DB subnet group name"
  value       = aws_db_subnet_group.db_subnet.name
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret managed by RDS"
  value       = aws_db_instance.database.master_user_secret[0].secret_arn
}