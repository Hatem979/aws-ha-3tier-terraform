variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for application instances"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least two private subnets are required."
  }
}

variable "app_security_group_id" {
  description = "Security Group ID attached to application instances"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB Target Group"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of application instances"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired number of application instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of application instances"
  type        = number
  default     = 4
}

variable "tags" {
  description = "Tags applied to resources"
  type        = map(string)
  default     = {}
}
variable "iam_instance_profile_name" {
  description = "Name of the IAM Instance Profile attached to EC2 instances."
  type        = string
}