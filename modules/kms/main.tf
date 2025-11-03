# KMS Key
resource "aws_kms_key" "this" {
  description              = var.description
  deletion_window_in_days  = var.deletion_window_in_days
  enable_key_rotation      = var.enable_key_rotation
  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
  multi_region             = var.multi_region
  policy                   = data.aws_iam_policy_document.combined.json

  tags = merge(var.global_tags, {
    Name        = var.key_name
    ManagedBy   = "Terraform"
    Environment = lookup(var.global_tags, "Environment", "unknown")
    Project     = lookup(var.global_tags, "Project", "unknown")
  })
}

# KMS Alias
resource "aws_kms_alias" "this" {
  name          = "alias/${var.global_tags["Project"]}-${var.global_tags["Environment"]}-${var.key_name}"
  target_key_id = aws_kms_key.this.key_id
}

# Política para administradores
data "aws_iam_policy_document" "administrators" {
  count = length(var.administrators) > 0 ? 1 : 0

  statement {
    sid    = "AllowAdministrators"
    effect = "Allow"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = var.administrators
    }
  }
}

# Política para usuarios
data "aws_iam_policy_document" "users" {
  count = length(var.users) > 0 ? 1 : 0

  statement {
    sid    = "AllowUsers"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = var.users
    }
  }
}

# Política para servicios AWS
data "aws_iam_policy_document" "services" {
  count = var.enable_default_policy ? 1 : 0

  statement {
    sid    = "AllowServices"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = [for service in var.services : "${service}.amazonaws.com"]
    }
  }
}

# Política del root account (siempre necesaria)
data "aws_iam_policy_document" "root" {
  statement {
    sid    = "EnableRootPermissions"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

# Combinar todas las políticas
data "aws_iam_policy_document" "combined" {
  source_policy_documents = compact([
    data.aws_iam_policy_document.root.json,
    try(data.aws_iam_policy_document.administrators[0].json, ""),
    try(data.aws_iam_policy_document.users[0].json, ""),
    try(data.aws_iam_policy_document.services[0].json, "")
  ])
}

# Data source para account ID actual
data "aws_caller_identity" "current" {}