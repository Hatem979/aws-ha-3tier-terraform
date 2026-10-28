variable "project_name" {
  description = "Project name used to identify monitoring resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the application target group"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Name of the application Auto Scaling Group"
  type        = string
}

variable "db_instance_id" {
  description = "Identifier of the RDS DB instance"
  type        = string
}

variable "alarm_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  default     = ""

  validation {
    condition = (
      var.alarm_email == "" ||
      can(regex("^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$", var.alarm_email))
    )
    error_message = "Provide a valid email address or leave alarm_email empty."
  }
}

variable "tags" {
  description = "Tags applied to supported resources"
  type        = map(string)
  default     = {}
}