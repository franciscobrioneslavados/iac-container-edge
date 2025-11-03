variable "global_tags" {
  description = "Global tags for all resources"
  type        = map(string)
  default     = {}
}

variable "deploy_efs" {
  description = "Enable EFS for persistent storage"
  type        = bool
}

variable "efs_name" {
  description = "Name of the EFS file system"
  type        = string
}

variable "efs_purpose" {
  description = "Purpose of the EFS"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EFS mount targets"
  type        = list(string)
}

variable "security_groups" {
  description = "Security group IDs to attach to EFS mount targets"
  type        = list(string)
  default     = []
}