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

variable "namespace_name" {
  description = "The name of the Service Connect namespace"
  type        = string
}