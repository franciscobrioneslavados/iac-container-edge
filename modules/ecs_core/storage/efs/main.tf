resource "aws_efs_file_system" "this" {
  creation_token = "efs-${var.project}-${var.environment}-${var.efs_name}"
  encrypted      = true
  tags = {
    Name = "efs-${var.project}-${var.environment}-${var.efs_name}"
  }
}

resource "aws_efs_mount_target" "this" {
  for_each = { for idx, subnet_id in var.private_subnet_ids : idx => subnet_id }


  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = [var.efs_security_group_id]
}
