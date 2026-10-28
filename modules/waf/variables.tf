
variable "project_name" {
  description = "Project name used to identify WAF resources."
  type        = string
}

variable "rate_limit" {
  description = "Maximum requests per five-minute evaluation window per IP before blocking."
  type        = number
  default     = 1000

  validation {
    condition     = var.rate_limit >= 100
    error_message = "The rate limit must be at least 100 requests."
  }
}

variable "tags" {
  description = "Common tags for supported resources."
  type        = map(string)
  default     = {}
}
