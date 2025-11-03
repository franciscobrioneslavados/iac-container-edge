variable "secret_name" {
  description = "Nombre del secret en Secrets Manager"
  type        = string
}

variable "global_tags" {
  description = "Tags globales para todos los recursos"
  type        = map(string)
  default     = {}
}

variable "generate_password" {
  description = "Generar automáticamente una contraseña segura"
  type        = bool
  default     = true
}

variable "custom_password" {
  description = "Contraseña personalizada (solo si generate_password es false)"
  type        = string
  default     = null
  sensitive   = true
}

variable "password_length" {
  description = "Longitud de la contraseña generada"
  type        = number
  default     = 16
}

variable "include_special_chars" {
  description = "Incluir caracteres especiales en la contraseña"
  type        = bool
  default     = false # PostgreSQL puede tener problemas con algunos caracteres
}

variable "description" {
  description = "Descripción del secret"
  type        = string
  default     = "Database password managed by Terraform"
}

variable "kms_key_id" {
  description = "KMS Key ID para encriptar el secret (opcional - si no se proporciona, se usará el default de AWS)"
  type        = string
  default     = null
}

variable "create_kms_key" {
  description = "Crear automáticamente una KMS key para este secret"
  type        = bool
  default     = false
}

variable "kms_key_config" {
  description = "Configuración para la KMS key (solo si create_kms_key es true)"
  type = object({
    description             = optional(string, "KMS key for Secrets Manager")
    enable_key_rotation     = optional(bool, true)
    deletion_window_in_days = optional(number, 7)
  })
  default = null
}

variable "enable_rotation" {
  description = "Habilitar rotación automática del secret"
  type        = bool
  default     = false
}

variable "rotation_days" {
  description = "Días entre rotaciones automáticas"
  type        = number
  default     = 30
}