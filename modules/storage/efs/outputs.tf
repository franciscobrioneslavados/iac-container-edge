output "efs_id" {
  description = "EFS File System ID (null if EFS not deployed)"
  value       = try(aws_efs_file_system.this["efs"].id, null)
}

output "efs_arn" {
  description = "EFS ARN (null if EFS not deployed)"
  value       = try(aws_efs_file_system.this["efs"].arn, null)
}

output "efs_creation_token" {
  description = "Creation token used for the EFS (null if not deployed)"
  value       = try(aws_efs_file_system.this["efs"].creation_token, null)
}

output "efs_mount_target_ids" {
  description = "List of EFS mount target IDs (empty if none)"
  value       = try([for mt in values(aws_efs_mount_target.postgresql) : mt.id], [])
}

output "efs_mount_subnet_ids" {
  description = "Subnet IDs used by the EFS mount targets (empty if none)"
  value       = try([for mt in values(aws_efs_mount_target.postgresql) : mt.subnet_id], [])
}
