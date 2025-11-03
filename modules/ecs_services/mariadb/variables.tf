variable "execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "ecs_cluster_id" {
  description = "ECS cluster ID where the service will be deployed"
  type        = string
}

variable "desired_count" {
  description = "Desired number of task instances"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ECS service"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the ECS service"
  type        = list(string)
}

variable "launch_type" {
  description = "Launch type for the ECS service (e.g., FARGATE)"
  type        = string
  default     = "FARGATE"
}

variable "discovery_service_arn" {
  description = "Service Discovery Service ARN for ECS service registration"
  type        = string
}

variable "deploy_efs" {
  description = "Enable EFS for persistent storage"
  type        = bool
}

variable "efs_id" {
  description = "EFS filesystem id (nullable)."
  type        = string
  default     = null
}

variable "create_database_secret" {
  description = "Crear automáticamente el secret de PostgreSQL"
  type        = bool
  default     = true
}

variable "database_password_arn" {
  description = "ARN del secret existente (solo si create_database_secret es false)"
  type        = string
  default     = null
}

variable "use_kms_encryption" {
  description = "Usar KMS personalizado para encriptar el secret"
  type        = bool
  default     = null # Null = automático basado en ambiente
}

variable "kms_key_id" {
  description = "KMS Key ID para encriptar el secret (solo si use_kms_encryption es true)"
  type        = string
  default     = null
}

variable "global_tags" {
  description = "Global tags for all resources"
  type        = map(string)
  default     = {}
}

