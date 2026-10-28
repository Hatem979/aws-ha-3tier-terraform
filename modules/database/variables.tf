variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "private_db_subnet_ids" {
  description = "IDs of private database subnets in different Availability Zones"
  type        = list(string)

  validation {
    condition     = length(var.private_db_subnet_ids) >= 2
    error_message = "At least two private database subnets are required."
  }
}

variable "database_security_group_id" {
  description = "Security Group ID attached to the RDS instance"
  type        = string
}

variable "database_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "database_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "dbadmin"
}

variable "database_instance_class" {
  description = "RDS DB instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial allocated storage in GiB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage size for autoscaling in GiB"
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Whether to deploy a Multi-AZ DB instance"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to supported resources"
  type        = map(string)
  default     = {}
}