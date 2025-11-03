output "ecs_task_definition_arn" {
  description = "ARN de la task definition de ECS"
  value       = aws_ecs_task_definition.this.arn
}

output "ecs_task_definition_family" {
  description = "Familia de la task definition"
  value       = aws_ecs_task_definition.this.family
}

output "cloudwatch_log_group_name" {
  description = "Nombre del grupo de logs de CloudWatch"
  value       = aws_cloudwatch_log_group.this.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN del grupo de logs de CloudWatch"
  value       = aws_cloudwatch_log_group.this.arn
}