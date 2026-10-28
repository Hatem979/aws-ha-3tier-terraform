variable "project_name" {
  description = "Name of the project used to identify IAM resources."
  type        = string
}

variable "secret_arn" {
  description = "ARN of the specific Secrets Manager secret the EC2 role may read. Leave null when access is not required."
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "Common tags applied to IAM resources."
  type        = map(string)
  default     = {}
}