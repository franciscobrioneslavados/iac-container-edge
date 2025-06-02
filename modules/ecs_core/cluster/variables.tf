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
