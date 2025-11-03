resource "aws_efs_file_system" "this" {
  for_each = var.deploy_efs ? { efs = var.efs_name } : {}

  creation_token = "${var.efs_name}-${var.global_tags["Environment"]}"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(var.global_tags, {
    Name = "${var.efs_name}-${var.global_tags["Environment"]}"
    Type = "${var.efs_purpose}"
  })
}

resource "aws_efs_mount_target" "postgresql" {
  for_each = var.deploy_efs ? { for idx, id in var.private_subnet_ids : idx => id } : {}

  file_system_id  = aws_efs_file_system.this["efs"].id
  subnet_id       = each.value
  security_groups = var.security_groups
}
