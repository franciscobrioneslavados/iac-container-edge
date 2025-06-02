variable "discovery_service_name" {
  description = "Service discovery name"
  type        = list(string)
  default     = ["default"]
}

variable "namespace_id" {
  description = "Cloud Map namespace ID"
  type        = string
  default     = "default.local"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the service discovery will be created"
  type        = string
}

variable "namespace_name" {
  description = "Name of the Cloud Map namespace"
  type        = string
  default     = "local"
}
