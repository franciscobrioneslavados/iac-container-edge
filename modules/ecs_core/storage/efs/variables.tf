variable "efs_name" {
  description = "Name of the EFS file system"
  type        = string
}

variable "environment" {
  description = "Environment variables for the ECS task"
  type        = string
}

variable "project" {
  description = "Project name for the ECS task"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the ECS task"
  type        = list(string)
}

variable "efs_security_group_id" {
  description = "Security Group ID for the EFS service"
  type        = string
}
