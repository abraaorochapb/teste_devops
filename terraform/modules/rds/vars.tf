variable "project_name" {
  type        = string
  description = "Project name"
  default     = "atividade-abraao"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_secret_name" {
  type        = string
  description = "Secrets Manager secret name for RDS credentials"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Instance class"
}

variable "allocated_storage" {
  type        = number
  default     = 10
  description = "Allocated storage in GB"
}
