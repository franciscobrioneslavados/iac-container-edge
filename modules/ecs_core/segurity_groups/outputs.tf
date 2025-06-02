
output "sg_wordpress_id" {
  description = "Security Group ID for the WordPress service"
  value       = aws_security_group.wordpress_sg.id
}

output "sg_postgresql_id" {
  description = "Security Group ID for the PostgreSQL service"
  value       = aws_security_group.postgresql_sg.id
}

output "sg_efs_id" {
  description = "Security Group ID for the EFS service"
  value       = aws_security_group.efs_sg.id
}
output "sg_alb_id" {
  description = "Security Group ID for the ELB service"
  value       = aws_security_group.alb_sg.id
}
