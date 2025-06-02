variable "vpc_cidr" {
  description = "default CIDR range of the VPC"
}
variable "aws_region" {
  description = "aws region"
}

variable "environment" {
  description = "aws environment"
  type        = string
  default     = "development"
}

variable "managed_by" {
  description = "value for the ManagedBy tag"
  type        = string
  default     = "Terraform"
}

variable "owner" {
  description = "value for the Owner tag"
  type        = string
}

variable "project" {
  description = "value for the Project tag"
  type        = string
}

variable "single_nat_gateway" {
  description = "true to use a single NAT gateway, false to use one per AZ"
  type        = bool
  default     = true
}

variable "public_ip_cidr" {
  description = "CIDR range for public IPs"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the service"
  type        = string
}

variable "nginx_image" {
  description = "Docker image for Nginx"
  type        = string
}