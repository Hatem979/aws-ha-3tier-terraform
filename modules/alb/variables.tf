variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the target group operates"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by the ALB"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "The ALB must use at least two public subnets."
  }
}

variable "alb_security_group_id" {
  description = "Security Group ID attached to the ALB"
  type        = string
}

variable "target_port" {
  description = "Port used by the application targets"
  type        = number
  default     = 80

  validation {
    condition     = var.target_port >= 1 && var.target_port <= 65535
    error_message = "target_port must be between 1 and 65535."
  }
}

variable "health_check_path" {
  description = "HTTP path used to check application health"
  type        = string
  default     = "/"
}

variable "tags" {
  description = "Tags applied to ALB resources"
  type        = map(string)
  default     = {}
}
variable "origin_verify_header_value" {
  description = "Custom header value used to verify requests arriving through CloudFront."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.origin_verify_header_value) >= 32
    error_message = "The origin verification header value must be at least 32 characters long."
  }
}