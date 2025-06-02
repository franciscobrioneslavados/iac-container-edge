output "service_name" {
  description = "Name of the WordPress ECS service"
  value       = aws_ecs_service.wordpress.name
}