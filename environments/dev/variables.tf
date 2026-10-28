
variable "aws_region" {
  description = "AWS Region for the deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "aws-ha-3tier"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateways for application subnets"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}

variable "s3_bucket_name" {
  description = "Globally unique name for the application S3 bucket."
  type        = string
}

variable "multi_az" {
  description = "Whether to use multiple availability zones for the database"
  type        = bool
  default     = true
}

variable "origin_verify_header_value" {
  description = "Custom value shared by CloudFront and the ALB listener rule."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.origin_verify_header_value) >= 32
    error_message = "The origin verification header value must be at least 32 characters long."
  }
}