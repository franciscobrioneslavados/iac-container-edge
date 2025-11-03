variable "key_name" {
  description = "Nombre descriptivo de la KMS key"
  type        = string
}

variable "description" {
  description = "Descripción de la KMS key"
  type        = string
  default     = "KMS key managed by Terraform"
}

variable "deletion_window_in_days" {
  description = "Días de espera antes de eliminar la key (7-30)"
  type        = number
  default     = 7

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Deletion window must be between 7 and 30 days."
  }
}

variable "enable_key_rotation" {
  description = "Habilitar rotación automática de la key"
  type        = bool
  default     = true
}

variable "key_usage" {
  description = "Uso de la key (ENCRYPT_DECRYPT, SIGN_VERIFY)"
  type        = string
  default     = "ENCRYPT_DECRYPT"

  validation {
    condition     = contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY"], var.key_usage)
    error_message = "Key usage must be ENCRYPT_DECRYPT or SIGN_VERIFY."
  }
}

variable "customer_master_key_spec" {
  description = "Especificación de la key (SYMMETRIC_DEFAULT, RSA_2048, etc.)"
  type        = string
  default     = "SYMMETRIC_DEFAULT"

  validation {
    condition     = contains(["SYMMETRIC_DEFAULT", "RSA_2048", "RSA_3072", "RSA_4096", "ECC_NIST_P256", "ECC_NIST_P384", "ECC_NIST_P521", "ECC_SECG_P256K1"], var.customer_master_key_spec)
    error_message = "Invalid key spec provided."
  }
}

variable "multi_region" {
  description = "Habilitar key multi-region"
  type        = bool
  default     = false
}

variable "global_tags" {
  description = "Tags globales para todos los recursos"
  type        = map(string)
  default     = {}
}

variable "administrators" {
  description = "Lista de ARNs de usuarios/roles con permisos de administración"
  type        = list(string)
  default     = []
}

variable "users" {
  description = "Lista de ARNs de usuarios/roles con permisos de uso"
  type        = list(string)
  default     = []
}

variable "services" {
  description = "Lista de servicios AWS que pueden usar esta key (secretsmanager, s3, etc.)"
  type        = list(string)
  default     = ["secretsmanager"]
}

variable "enable_default_policy" {
  description = "Habilitar política por defecto para servicios AWS"
  type        = bool
  default     = true
}