variable "environment" {
  description = "AWS environment"
  type        = string
  default     = "development"
}

variable "project" {
  description = "Project name for tagging"
  type        = string
  default     = "container-edge"
}

variable "global_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}