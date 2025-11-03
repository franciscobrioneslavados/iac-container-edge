output "alb_security_group_id" {
  description = "ID del Security Group del ALB"
  value       = aws_security_group.alb_sg["alb"].id
}

output "ecs_security_group_ids" {
  description = "IDs de los Security Groups de ECS"
  value       = { for k, v in aws_security_group.ecs_sg : k => v.id }
}

output "efs_security_group_id" {
  description = "ID del Security Group de EFS"
  value       = aws_security_group.efs_sg["efs"].id
}

output "wordpress_security_group_id" {
  description = "ID del Security Group de WordPress"
  value       = aws_security_group.ecs_sg["wordpress"].id
}