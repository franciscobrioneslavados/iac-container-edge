variable "environment" {
  description = "AWS environment"
  type        = string
  default     = "development"
}

variable "project" {
  description = "Project name for tagging"
  type        = string
  default     = "vpc_default"
}

variable "vpc_id" {
  description = "VPC ID where the security groups will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  
}
