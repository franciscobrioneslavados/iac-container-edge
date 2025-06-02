output "service_name" {
  description = "Name of the WordPress ECS service"
  value       = aws_ecs_service.wordpress.name
}
output "service_id" {
  description = "ID of the WordPress ECS service"
  value       = aws_ecs_service.wordpress.id
}