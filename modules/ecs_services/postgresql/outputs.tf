output "service_name" {
  value = aws_ecs_service.postgresql.name
}
output "service_id" {
  value = aws_ecs_service.postgresql.id
}