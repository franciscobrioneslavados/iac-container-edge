variable "execution_role_arn" {
  description = "ARN del rol de ejecución de la tarea ECS"
  type        = string
}

variable "project" {
  description = "Nombre del proyecto para la tarea ECS"
  type        = string
}

variable "environment" {
  description = "Nombre del entorno para la tarea ECS"
  type        = string
}

variable "efs_id" {
  description = "ID del sistema de archivos EFS para WordPress"
  type        = string
}

variable "ecs_cluster_id" {
  description = "ID del clúster ECS"
  type        = string
}

variable "desired_count" {
  description = "values for the desired count of the ECS service"
  type        = number
  default     = 1
}

variable "launch_type" {
  description = "Launch type for the ECS service (FARGATE or EC2)"
  type        = string
  default     = "FARGATE"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ECS service"
  type        = list(string)
}

variable "registry_arn" {
  description = "ARN of the service registry for the ECS service"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for the ECS service"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the target group for the ECS service"
  type        = string
  default     = null
}