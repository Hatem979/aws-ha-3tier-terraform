
variable "project_name" {
  description = "Project name used to identify the S3 bucket."
  type        = string
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string

  validation {
    condition = (
      length(var.bucket_name) >= 3 &&
      length(var.bucket_name) <= 63 &&
      can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.bucket_name)) &&
      !strcontains(var.bucket_name, "..") &&
      !can(regex("[.-][.-]", var.bucket_name))
    )
    error_message = "The bucket name must be 3-63 characters, use lowercase letters, numbers, dots or hyphens, and not contain consecutive periods or adjacent period/hyphen combinations."
  }
}

variable "tags" {
  description = "Common tags applied to supported resources."
  type        = map(string)
  default     = {}
}
