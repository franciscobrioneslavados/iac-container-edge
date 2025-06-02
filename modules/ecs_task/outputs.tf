output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.this.arn
}

output "ecs_task_definition_family" {
  description = "Family name of the ECS task definition"
  value       = aws_ecs_task_definition.this.family
}
