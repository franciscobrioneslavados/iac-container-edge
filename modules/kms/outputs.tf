output "key_arn" {
  description = "ARN de la KMS key"
  value       = aws_kms_key.this.arn
}

output "key_id" {
  description = "ID de la KMS key"
  value       = aws_kms_key.this.key_id
}

output "alias_arn" {
  description = "ARN del alias de la KMS key"
  value       = aws_kms_alias.this.arn
}

output "alias_name" {
  description = "Nombre del alias de la KMS key"
  value       = aws_kms_alias.this.name
}

output "key_policy" {
  description = "Política completa de la KMS key"
  value       = aws_kms_key.this.policy
  sensitive   = true
}

# Outputs para uso específico
output "for_secrets_manager" {
  description = "Configuración para usar con Secrets Manager"
  value = {
    kms_key_id = aws_kms_key.this.key_id
    key_arn    = aws_kms_key.this.arn
    alias_name = aws_kms_alias.this.name
  }
}

output "for_efs" {
  description = "Configuración para usar con EFS"
  value = {
    kms_key_id = aws_kms_key.this.key_id
    key_arn    = aws_kms_key.this.arn
  }
}

output "for_s3" {
  description = "Configuración para usar con S3"
  value = {
    kms_key_id = aws_kms_key.this.key_id
    key_arn    = aws_kms_key.this.arn
    alias_arn  = aws_kms_alias.this.arn
  }
}