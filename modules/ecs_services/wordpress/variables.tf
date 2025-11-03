variable "execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "ecs_cluster_id" {
  description = "ID del clúster ECS"
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
  description = "Launch type for the ECS service (FARGATE or EC2)"
  type        = string
  default     = "FARGATE"
}

variable "discovery_service_arn" {
  description = "Service Discovery Service ARN for ECS service registration"
  type        = string
}

variable "mariadb_service_endpoint" {
  description = "Endpoint to connect to the MariaDB service"
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

variable "database_password_arn" {
  type        = string
  description = "ARN del secret de MariaDB (QA/Prod)"
  default     = null
}

variable "database_password_plain" {
  type        = string
  description = "Password en texto plano para dev"
  default     = null
}
variable "global_tags" {
  description = "Global tags for all resources"
  type        = map(string)
  default     = {}
}

