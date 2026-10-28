variable "project_name" {
  description = "project name used in resource names and tags."
  type        = string
}
variable "vpc_id" {
  description = "ID of the VPC where security groups will be created."
  type        = string
}
variable "private_app_port" {
  description = "Port used by application behind the ALB."
  type        = number
  default     = 80
  validation {
    condition     = var.private_app_port > 0 && var.private_app_port < 65536
    error_message = "The private application port must be between 1 and 65535."
  }
}
variable "private_db_port" {
  description = "Port for the private database security group."
  type        = number
  default     = 3306
  validation {
    condition     = var.private_db_port >= 0 && var.private_db_port <= 65536
    error_message = "The private database port must be between 1 and 65535."
  }
}
variable "alb_ingress_cidr" {
  description = "IPV4 CIDR Ranges allowed for ALB ingress traffic."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "tags" {
  description = "Common tags for security group resources."
  type        = map(string)
  default     = {}
}