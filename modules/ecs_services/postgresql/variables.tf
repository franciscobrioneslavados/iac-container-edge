variable "execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "efs_id" {
  description = "EFS ID for persistent storage"
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

variable "registry_arn" {
  description = "ARN of the service registry for ECS service discovery"
  type        = string
}

variable "global_tags" {
  description = "Global tags for all resources"
  type        = map(string)
  default     = {}
}