# KMS Key para el secret (opcional)
module "secret_kms_key" {
  source = "../kms"
  count  = var.create_kms_key ? 1 : 0

  key_name                = "${var.secret_name}-key"
  description             = try(var.kms_key_config.description, "KMS key for secret ${var.secret_name}")
  enable_key_rotation     = try(var.kms_key_config.enable_key_rotation, true)
  deletion_window_in_days = try(var.kms_key_config.deletion_window_in_days, 7)
  global_tags             = var.global_tags
  services                = ["secretsmanager"]

  # Permitir que el usuario actual administre la key
  administrators = [data.aws_caller_identity.current.arn]
}

# Local para determinar qué KMS key usar
locals {
  final_kms_key_id = var.kms_key_id != null ? var.kms_key_id : (
    var.create_kms_key ? module.secret_kms_key[0].key_id : null
  )
}

# Generar contraseña segura
resource "random_password" "this" {
  count = var.generate_password ? 1 : 0

  length           = var.password_length
  special          = var.include_special_chars
  override_special = "!@#$%^&*()_+-=[]{}|:"

  # Para PostgreSQL, evitar caracteres problemáticos
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = var.include_special_chars ? 1 : 0
}

# Secret en Secrets Manager
resource "aws_secretsmanager_secret" "this" {
  name        = var.secret_name
  description = var.description
  kms_key_id  = local.final_kms_key_id # Usar KMS key personalizada o null para default

  tags = merge(var.global_tags, {
    Name        = var.secret_name
    ManagedBy   = "Terraform"
    Environment = lookup(var.global_tags, "Environment", "unknown")
    KMSKey      = local.final_kms_key_id != null ? "custom" : "default"
  })
}

# Versión del secret
resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = var.generate_password ? random_password.this[0].result : (
    var.custom_password != null ? var.custom_password : jsonencode({
      error = "No se proporcionó contraseña y generate_password es false"
    })
  )
}

# Política de rotación automática (opcional)
resource "aws_secretsmanager_secret_rotation" "this" {
  count = var.enable_rotation ? 1 : 0

  secret_id           = aws_secretsmanager_secret.this.id
  rotation_lambda_arn = null # Podrías agregar una Lambda personalizada después

  rotation_rules {
    automatically_after_days = var.rotation_days
  }
}

# Data source para account ID actual
data "aws_caller_identity" "current" {}