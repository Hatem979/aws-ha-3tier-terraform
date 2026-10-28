output "sns_topic_arn" {
  description = "ARN of the CloudWatch alerts SNS topic"
  value       = aws_sns_topic.alerts.arn
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch monitoring dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "alb_5xx_alarm_name" {
  description = "Name of the ALB 5XX alarm"
  value       = aws_cloudwatch_metric_alarm.alb_5xx.alarm_name
}

output "target_5xx_alarm_name" {
  description = "Name of the application target 5XX alarm"
  value       = aws_cloudwatch_metric_alarm.target_5xx.alarm_name
}

output "rds_cpu_alarm_name" {
  description = "Name of the RDS CPU alarm"
  value       = aws_cloudwatch_metric_alarm.rds_cpu.alarm_name
}

output "rds_low_storage_alarm_name" {
  description = "Name of the RDS low storage alarm"
  value       = aws_cloudwatch_metric_alarm.rds_low_storage.alarm_name
}

output "asg_capacity_alarm_name" {
  description = "Name of the ASG capacity alarm"
  value       = aws_cloudwatch_metric_alarm.asg_capacity.alarm_name
}