variable "vpc_id" {
  description = "VPC ID where the security groups will be created"
  type        = string
}

variable "cidr_blocks" {
  description = "CIDR blocks for security group rules"
  type        = string
}

variable "global_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
