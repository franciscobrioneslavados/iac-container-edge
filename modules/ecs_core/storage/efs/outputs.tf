output "efs_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.this.id

}

output "efs_mount_targets" {
  description = "Map of EFS mount targets by subnet ID"
  value       = { for k, v in aws_efs_mount_target.this : k => v.id }
}

output "efs_dns_name" {
  description = "DNS name of the EFS file system"
  value       = aws_efs_file_system.this.dns_name
}

output "efs_arn" {
  description = "ARN of the EFS file system"
  value       = aws_efs_file_system.this.arn
}
