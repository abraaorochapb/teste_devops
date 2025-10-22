variable "project_name" {
  description = "Project name"
  type        = string
  default     = "teste-abraao"
}

variable "eks_version" {
  description = "EKS version"
  type        = string
  default     = "1.34"
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = "teste_abraao"
}