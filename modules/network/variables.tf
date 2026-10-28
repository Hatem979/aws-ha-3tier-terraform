variable "project_name" {
  description = "name perfix for all network resources."
  type        = string
  default     = "aws-ha-3tier"
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "The number of public subnet CIDRs must match the number of Availability Zones."
  }
}
variable "private_app_subnet_cidrs" {
  description = "List of CIDR blocks for the private application subnets."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
  validation {
    condition     = length(var.private_app_subnet_cidrs) == length(var.availability_zones)
    error_message = "The number of private application subnet CIDRs must match the number of Availability Zones."
  }
}
variable "private_db_subnet_cidrs" {
  description = "List of CIDR blocks for the private database subnets."
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
  validation {
    condition     = length(var.private_db_subnet_cidrs) == length(var.availability_zones)
    error_message = "The number of private database subnet CIDRs must match the number of Availability Zones."
  }
}
variable "availability_zones" {
  description = "Two availability zones in the selected region."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly two availability zones must be provided."
  }
}
variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway per Availability Zone."
  type        = bool
  default     = false
}
variable "tags" {
  description = "Common tags for network resources."
  type        = map(string)
  default     = {}
}