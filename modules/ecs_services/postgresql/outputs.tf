output "service_name" {
  value = aws_ecs_service.postgresql.name
}
output "service_id" {
  value = aws_ecs_service.postgresql.id
}

output "database_password_arn" {
  description = "ARN del secret usado por PostgreSQL (null si no usado)"
  value       = local.has_valid_secret ? local.final_database_password_arn : null
}