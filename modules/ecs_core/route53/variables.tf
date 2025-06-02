variable "domain_name" {
  description = "Nombre de dominio para la zona hospedada en Route 53"
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
