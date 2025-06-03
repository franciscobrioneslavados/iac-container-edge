variable "global_tags" {
  description = "Global tags for all resources"
  type        = map(string)
  default     = {}
}

variable "domain_name" {
  description = "Domain name for the Route 53 hosted zone"
  type        = string
}

variable "zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}