variable "service_name" {
  description = "Nombre del servicio ECS"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN del rol de ejecución de ECS"
  type        = string
}

variable "network_mode" {
  description = "Modo de red (awsvpc, bridge, host)"
  type        = string
  default     = "awsvpc"
}

variable "requires_compatibilities" {
  description = "Compatibilidades requeridas (FARGATE, EC2)"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "cpu" {
  description = "CPU units para el task"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memoria para el task (MB)"
  type        = string
  default     = "512"
}

variable "global_tags" {
  description = "Tags globales para todos los recursos"
  type        = map(string)
  default     = {}
}

variable "task_role_arn" {
  description = "ARN del rol del task (opcional)"
  type        = string
  default     = null
}

variable "essential" {
  description = "Si el contenedor es esencial"
  type        = bool
  default     = true
}

variable "service_config" {
  description = "Configuración completa del servicio"
  type = object({
    image = string
    port_mappings = optional(list(object({
      container_port = number
      host_port      = optional(number, 0)
      protocol       = optional(string, "tcp")

    })), [])
    environment = optional(map(string), {})
    secrets     = optional(map(string), {})
    volumes = optional(list(object({
      name               = string
      efs_id             = optional(string)
      host_path          = optional(string)
      root_directory     = optional(string, "/")
      transit_encryption = optional(string, "ENABLED")
    })), [])
    mount_points = optional(list(object({
      source_volume  = string
      container_path = string
      read_only      = optional(bool, false)
    })), [])
    health_check = optional(object({
      command     = list(string)
      interval    = optional(number, 30)
      timeout     = optional(number, 5)
      retries     = optional(number, 3)
      startPeriod = optional(number, 0)
    }))
    log_configuration = optional(object({
      log_driver = optional(string, "awslogs")
      options    = optional(map(string), {})
    }))
    entry_point       = optional(list(string), [])
    command           = optional(list(string), [])
    working_directory = optional(string)
    linux_parameters = optional(object({
      capabilities = optional(object({
        add  = optional(list(string), [])
        drop = optional(list(string), [])
      }))
    }))
    depends_on = optional(list(object({
      container_name = string
      condition      = string
    })), [])
  })
}
