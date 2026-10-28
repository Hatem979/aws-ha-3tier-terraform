
variable "project_name" {
  description = "Project name used to identify CloudFront resources."
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  type        = string
}

variable "s3_bucket_id" {
  description = "ID/name of the private S3 bucket."
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the private S3 bucket."
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket."
  type        = string
}

variable "tags" {
  description = "Common tags applied to supported resources."
  type        = map(string)
  default     = {}
}

variable "waf_web_acl_arn" {
  description = "ARN of the AWS WAF Web ACL associated with CloudFront."
  type        = string
}
variable "origin_verify_header_value" {
  description = "Custom header value CloudFront sends to the ALB origin."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.origin_verify_header_value) >= 32
    error_message = "The origin verification header value must be at least 32 characters long."
  }
}