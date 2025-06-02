variable "environment" {
  description = "Environment variables for the ECS task"
  type        = string
}

variable "project" {
  description = "Project name for the ECS task"
  type        = string
}

variable "service_name" {
  description = "Nombre del servicio ECS"
  type        = string
}

variable "network_mode" {
  description = "Modo de red para la tarea ECS (awsvpc, bridge, host)"
  type        = string
  default     = "awsvpc"
}

variable "requires_compatibilities" {
  description = "Compatibilidades requeridas para la tarea ECS (FARGATE, EC2)"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "cpu" {
  description = "Cantidad de CPU para la tarea ECS"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Cantidad de memoria para la tarea ECS"
  type        = string
  default     = "512"
}

variable "execution_role_arn" {
  description = "ARN del rol de ejecución de la tarea ECS"
  type        = string
}

variable "service_config" {
  type = object({
    image = string
    port_mappings = list(object({
      container_port = number
      host_port      = number
      protocol       = optional(string)
    }))
    environment = optional(map(string), {})
    secrets     = optional(map(string), {})
    volumes = optional(list(object({
      name           = string
      host_path      = optional(string)
      efs_id         = optional(string)
      root_directory = optional(string)
    })), [])
  })
}
