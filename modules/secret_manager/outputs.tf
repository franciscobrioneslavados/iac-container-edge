output "secret_arn" {
  description = "ARN del secret en Secrets Manager"
  value       = aws_secretsmanager_secret.this.arn
}

output "secret_name" {
  description = "Nombre del secret"
  value       = aws_secretsmanager_secret.this.name
}

output "secret_id" {
  description = "ID del secret"
  value       = aws_secretsmanager_secret.this.id
}

output "password" {
  description = "Contraseña generada (sensible)"
  value       = var.generate_password ? random_password.this[0].result : var.custom_password
  sensitive   = true
}

output "secret_version_id" {
  description = "ID de la versión del secret"
  value       = aws_secretsmanager_secret_version.this.version_id
}

# Output para usar directamente en ECS
output "ecs_secret_reference" {
  description = "Referencia del secret para ECS task definitions"
  value = {
    arn  = aws_secretsmanager_secret.this.arn
    name = aws_secretsmanager_secret.this.name
  }
}

output "kms_key_id" {
  description = "KMS Key ID usado para encriptar el secret"
  value       = local.final_kms_key_id
}

output "kms_key_arn" {
  description = "ARN de la KMS key (si se creó una)"
  value       = var.create_kms_key ? module.secret_kms_key[0].key_arn : null
}