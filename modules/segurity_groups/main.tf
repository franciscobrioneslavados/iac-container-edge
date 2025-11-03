############################
# LOCALS
############################
locals {
  # Servicios ECS
  ecs_services = {
    wordpress  = "WordPress Frontend"
    react      = "React Frontend"
    angular    = "Angular Frontend"
    nestjs     = "NestJS Backend API"
    python     = "Python Backend API"
    postgresql = "PostgreSQL Database"
    mariadb    = "MariaDB Database"
  }

  # EFS
  efs_services = {
    efs = "EFS Access"
  }

  # ALB
  alb_services = {
    alb = "Application Load Balancer"
  }

  # Conexiones ALB → ECS (solo para egress del ALB)
  alb_connections = [
    { from = "alb", to = "wordpress", port = 8080 },
    { from = "alb", to = "react", port = 80 },
    { from = "alb", to = "angular", port = 80 },
  ]

  # Conexiones internas entre servicios ECS
  ecs_connections = [
    # Frontends → Backends
    { from = "react", to = "nestjs", port = 3000 },
    { from = "react", to = "python", port = 5000 },
    { from = "angular", to = "nestjs", port = 3000 },
    { from = "angular", to = "python", port = 5000 },

    # Backends → Database
    { from = "wordpress", to = "mariadb", port = 3306 },
    { from = "nestjs", to = "mariadb", port = 3306 },
    { from = "python", to = "mariadb", port = 3306 },

    # EFS Access
    { from = "wordpress", to = "efs", port = 2049 },
    { from = "mariadb", to = "efs", port = 2049 },
    { from = "postgresql", to = "efs", port = 2049 },
  ]
}

############################
# SG ALB
############################
resource "aws_security_group" "alb_sg" {
  for_each    = local.alb_services
  name        = "${var.global_tags["ProjectName"]}-${var.global_tags["Environment"]}-alb-sg"
  description = "SG for ${each.value}"
  vpc_id      = var.vpc_id

  tags = merge(var.global_tags, {
    Name = "${var.global_tags["ProjectName"]}-${var.global_tags["Environment"]}-alb-sg"
  })
}

############################
# REGLAS DE INGRESS ALB (Acceso desde Internet)
############################
resource "aws_security_group_rule" "alb_http_ingress" {
  security_group_id = aws_security_group.alb_sg["alb"].id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow HTTP from internet"
}

resource "aws_security_group_rule" "alb_https_ingress" {
  security_group_id = aws_security_group.alb_sg["alb"].id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow HTTPS from internet"
}

############################
# REGLAS DE EGRESS ALB (Hacia servicios ECS)
############################
resource "aws_security_group_rule" "alb_egress_services" {
  for_each = {
    for c in local.alb_connections : "${c.from}-${c.to}-${c.port}" => c
  }

  type                     = "egress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb_sg["alb"].id
  source_security_group_id = aws_security_group.ecs_sg[each.value.to].id
  description              = "Allow egress from ALB to ${each.value.to} on port ${each.value.port}"
}

############################
# SG ECS
############################
resource "aws_security_group" "ecs_sg" {
  for_each    = local.ecs_services
  name        = "${var.global_tags["ProjectName"]}-${var.global_tags["Environment"]}-${each.key}-sg"
  description = "SG for ${each.value}"
  vpc_id      = var.vpc_id

  tags = merge(var.global_tags, {
    Name = "${var.global_tags["ProjectName"]}-${var.global_tags["Environment"]}-${each.key}-sg"
  })
}

############################
# SG EFS
############################
resource "aws_security_group" "efs_sg" {
  for_each    = local.efs_services
  name        = "${var.global_tags["ProjectName"]}-${var.global_tags["Environment"]}-efs-sg"
  description = "SG for ${each.value}"
  vpc_id      = var.vpc_id

  tags = merge(var.global_tags, {
    Name = "${var.global_tags["ProjectName"]}-${var.global_tags["Environment"]}-efs-sg"
  })
}

############################
# REGLAS DE INGRESS ECS (desde ALB y otros servicios ECS)
############################
resource "aws_security_group_rule" "ecs_ingress" {
  for_each = {
    for c in concat(local.alb_connections, local.ecs_connections) : "${c.from}-${c.to}-${c.port}" => c
  }

  type                     = "ingress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  security_group_id        = each.value.to == "efs" ? aws_security_group.efs_sg["efs"].id : aws_security_group.ecs_sg[each.value.to].id
  source_security_group_id = each.value.from == "alb" ? aws_security_group.alb_sg["alb"].id : aws_security_group.ecs_sg[each.value.from].id
  description              = "Allow ${each.value.from} to ${each.value.to} on port ${each.value.port}"
}

############################
# EGRESS HTTPS DESDE ECS
############################
resource "aws_security_group_rule" "ecs_https_egress" {
  for_each = aws_security_group.ecs_sg

  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = each.value.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow outbound HTTPS from ${each.key}"
}

############################
# EGRESS HTTP DESDE ECS (para servicios que necesitan comunicarse externamente)
############################
resource "aws_security_group_rule" "ecs_http_egress" {
  for_each = aws_security_group.ecs_sg

  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = each.value.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow outbound HTTP from ${each.key}"
}

############################
# REGLAS DE EGRESS PARA COMUNICACIÓN ENTRE SERVICIOS ECS (excluyendo ALB)
############################
resource "aws_security_group_rule" "ecs_egress_services" {
  for_each = {
    for c in local.ecs_connections : "${c.from}-${c.to}-${c.port}" => c
  }

  type                     = "egress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_sg[each.value.from].id
  source_security_group_id = each.value.to == "efs" ? aws_security_group.efs_sg["efs"].id : aws_security_group.ecs_sg[each.value.to].id
  description              = "Allow egress from ${each.value.from} to ${each.value.to} on port ${each.value.port}"
}