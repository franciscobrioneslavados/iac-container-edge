output "service_name" {
  value = aws_ecs_service.mariadb.name
}
output "service_id" {
  value = aws_ecs_service.mariadb.id
}

output "database_password_arn" {
  description = "ARN del secret usado por MariaDB (null si no usado)"
  value       = local.should_use_secret_mgr ? module.mariadb_secret[0].secret_arn : null
}

output "database_password_plain" {
  description = "Password en texto plano (solo en dev)"
  value       = local.should_use_secret_mgr ? null : random_password.mariadb_dev[0].result
}