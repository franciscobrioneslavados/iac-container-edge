variable "aws_region" {
  description = "aws region"
  default     = "us-east-1"
}
variable "vpc_id" {
  description = "ID of the VPC where resources will be deployed"
  default     = "vpc-031fe67ff94c9e969"
}

variable "cidr_blocks" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/22"
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for resource deployment"
  default     = ["subnet-0362da2f59b930c81", "subnet-09f80295e8614c8f5"]
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for resource deployment"
  default     = ["subnet-040d34ee35d11b700", "subnet-04ba5aadfb8418f9f"]
}

variable "environment" {
  description = "aws environment"
  type        = string
  default     = "development"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "El ambiente debe ser: development, staging, o production."
  }
}

variable "managed_by" {
  description = "value for the ManagedBy tag"
  type        = string
  default     = "Terraform"
}

variable "owner_name" {
  description = "value for the Owner tag"
  type        = string
  default     = "Francisco Briones"
}

variable "project_name" {
  description = "value for the Project tag"
  type        = string
  default     = "iac-container-edge"
}

variable "namespace_info" {
  description = "Service Discovery Namespace information"
  type = object({
    id   = string
    name = string
    arn  = string
  })
  default = {
    id   = "ns-uhwsfxk3x62vtiwx"
    name = "container-edge-development.local"
    arn  = "arn:aws:servicediscovery:us-east-1:613608381466:namespace/ns-uhwsfxk3x62vtiwx"
  }
}

variable "index_html" {
  description = "HTML que servirá la ruta raíz (/) del proxy"
  type        = string
  default     = "<h1>Welcome</h1>"
}

variable "namespace_name" {
  description = "Nombre del namespace para Service Discovery"
  type        = string
  default     = "container-edge-development.local"
}