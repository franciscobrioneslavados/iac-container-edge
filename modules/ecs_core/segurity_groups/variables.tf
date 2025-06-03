variable "vpc_id" {
  description = "VPC ID where the security groups will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "global_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
