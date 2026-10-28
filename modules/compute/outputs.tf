output "launch_template_id" {
  description = "ID of the application Launch Template"
  value       = aws_launch_template.app.id
}

output "autoscaling_group_name" {
  description = "Name of the application Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "autoscaling_group_arn" {
  description = "ARN of the application Auto Scaling Group"
  value       = aws_autoscaling_group.app.arn
}