variable "project_name" {
  description = "Project name"
  type        = string
  default     = "teste"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "eks_version" {
  description = "EKS version"
  type        = string
  default     = "1.34"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
}

variable "AmiTypeInstance" {
  description = "EKS Node Group AMI type"
  type        = string
  default     = "AL2_x86_64"
}

variable "InstanceTypes" {
  description = "EKS Node Group instance types"
  type        = list(string)
  default     = ["t3a.small"]
}

variable "scaling_config" {
  type = map(object({
    desired_size = number
    max_size     = number
    min_size     = number
  }))

  default = {
    "default_config" = {
      desired_size = 1
      max_size     = 2
      min_size     = 1
    }
  }
}