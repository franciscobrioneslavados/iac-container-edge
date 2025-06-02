variable "alb_name" {
  description = "Nombre del Application Load Balancer (ALB)"
  type        = string
}
variable "alb_internal" {
  description = "Indica si el ALB es interno"
  type        = bool
  default     = false
}
variable "alb_security_groups" {
  description = "Lista de grupos de seguridad para el ALB"
  type        = list(string)
}
variable "alb_subnets" {
  description = "Lista de subredes para el ALB"
  type        = list(string)
}
variable "vpc_id" {
  description = "ID del VPC donde se desplegará el ALB"
  type        = string
}
variable "wordpress_target_group_name" {
  description = "Nombre del grupo de destino para WordPress"
  type        = string
}

variable "react_target_group_name" {
  description = "Nombre del grupo de destino para React"
  type        = string
}

variable "domain_name" {
  description = "Nombre de dominio para el ALB"
  type        = string
}