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

variable "vpc_cidr" {
  default     = "10.20.0.0/19"
  description = "CIDR range of the VPC"
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
  description = "true to use a single NAT gateway, false to use one per AZ"
}

variable "global_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}


