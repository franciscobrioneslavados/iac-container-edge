variable "domain_name" {
  description = "Nombre de dominio para la zona hospedada en Route 53"
  type        = string
}

variable "zone_id" {
  description = "ID de la zona hospedada en Route 53"
  type        = string
}

variable "alb_dns_name" {
  description = "Nombre DNS del Application Load Balancer (ALB)"
  type        = string
}

variable "alb_zone_id" {
  description = "ID de la zona del Application Load Balancer (ALB)"
  type        = string
}

variable "enable_failover" {
  description = "Habilitar la conmutación por error en Route 53"
  type        = bool
  default     = false
}

variable "secondary_alb_dns_name" {
  description = "Secondary ALB DNS name for failover"
  type        = string
  default     = ""
}

variable "secondary_alb_zone_id" {
  description = "Secondary ALB Zone ID for failover"
  type        = string
  default     = ""
}

variable "global_tags" {
  description = "Etiquetas globales para todos los recursos"
  type        = map(string)
  default     = {}
}