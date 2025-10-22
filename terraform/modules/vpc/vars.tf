#  General vars 
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "teste"
}

# vpc vars
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "20.0.0.0/16"
}

variable "vpc_public_subnet_count" {
  description = "Number of public subnets in the VPC"
  type        = number
  default     = 2
}

variable "vpc_private_subnet_count" {
  description = "Number of private subnets in the VPC"
  type        = number
  default     = 2
}
