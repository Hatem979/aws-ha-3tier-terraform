output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.alb.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "target_group_arn" {
  description = "ARN of the application Target Group"
  value       = aws_lb_target_group.app.arn
}

output "http_listener_arn" {
  description = "ARN of the HTTP Listener"
  value       = aws_lb_listener.http.arn
}