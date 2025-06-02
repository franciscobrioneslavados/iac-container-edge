#############################
# Security Groups
#############################

resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}-${var.project}-alb-sg"
  description = "Security Group for Application Load Balancer"
  vpc_id      = var.vpc_id
  tags = {
    "Name" = "${var.environment}-${var.project}-alb-sg"
  }
}

resource "aws_security_group" "wordpress_sg" {
  name        = "${var.environment}-${var.project}-wordpress-sg"
  description = "Security Group for WordPress"
  vpc_id      = var.vpc_id
  tags = {
    "Name" = "${var.environment}-${var.project}-wordpress-sg"
  }
}

resource "aws_security_group" "postgresql_sg" {
  name        = "${var.environment}-${var.project}-postgresql-sg"
  description = "Security Group for PostgreSQL"
  vpc_id      = var.vpc_id
  tags = {
    "Name" = "${var.environment}-${var.project}-postgresql-sg"
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "${var.environment}-${var.project}-efs-sg"
  description = "Security Group for EFS access"
  vpc_id      = var.vpc_id
  tags = {
    "Name" = "${var.environment}-${var.project}-efs-sg"
  }
}

resource "aws_security_group" "react_sg" {
  name        = "${var.environment}-${var.project}-react-sg"
  description = "Security Group for React frontend"
  vpc_id      = var.vpc_id
  tags = {
    "Name" = "${var.environment}-${var.project}-react-sg"
  }
}

resource "aws_security_group" "nestjs_sg" {
  name        = "${var.environment}-${var.project}-nestjs-sg"
  description = "Security Group for NestJS backend"
  vpc_id      = var.vpc_id
  tags = {
    "Name" = "${var.environment}-${var.project}-nestjs-sg"
  }
}


#############################
# ALB Security Group Rules
#############################

# ALB Ingress HTTP
resource "aws_security_group_rule" "alb_http_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP traffic from anywhere"
}

# ALB Ingress HTTPS
resource "aws_security_group_rule" "alb_https_in" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTPS traffic from anywhere"
}

# ALB Egress to WordPress HTTP (80)
resource "aws_security_group_rule" "alb_wordpress_out" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.wordpress_sg.id
  security_group_id        = aws_security_group.alb_sg.id
  description              = "Allow HTTP traffic to WordPress"
}

# ALB Egress to React HTTP/HTTPS (80 and 443)
resource "aws_security_group_rule" "alb_react_http_out" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.react_sg.id
  security_group_id        = aws_security_group.alb_sg.id
  description              = "Allow HTTP traffic to React"
}

resource "aws_security_group_rule" "alb_react_https_out" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.react_sg.id
  security_group_id        = aws_security_group.alb_sg.id
  description              = "Allow HTTPS traffic to React"
}

# ALB Egress general (allow all outbound)
resource "aws_security_group_rule" "alb_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow all outbound traffic"
}


#############################
# WordPress Security Group Rules
#############################

# WordPress Ingress HTTP from ALB
resource "aws_security_group_rule" "wordpress_http_in" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.wordpress_sg.id
  description              = "Allow HTTP traffic from ALB"
}

# WordPress Egress to EFS (NFS 2049)
resource "aws_security_group_rule" "wordpress_efs_out" {
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.efs_sg.id
  security_group_id        = aws_security_group.wordpress_sg.id
  description              = "Allow NFS traffic to EFS"
}

# WordPress Egress to PostgreSQL (5432)
resource "aws_security_group_rule" "wordpress_postgres_out" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.postgresql_sg.id
  security_group_id        = aws_security_group.wordpress_sg.id
  description              = "Allow PostgreSQL traffic to WordPress"
}

# WordPress Egress general (all outbound)
resource "aws_security_group_rule" "wordpress_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.wordpress_sg.id
  description       = "Allow all outbound traffic"
}


#############################
# PostgreSQL Security Group Rules
#############################

# PostgreSQL Ingress from WordPress (5432)
resource "aws_security_group_rule" "postgresql_in_wordpress" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.wordpress_sg.id
  security_group_id        = aws_security_group.postgresql_sg.id
  description              = "Allow PostgreSQL access from WordPress"
}

# PostgreSQL Ingress from NestJS (5432)
resource "aws_security_group_rule" "postgresql_in_nestjs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nestjs_sg.id
  security_group_id        = aws_security_group.postgresql_sg.id
  description              = "Allow PostgreSQL access from NestJS backend"
}

# PostgreSQL Egress to EFS (2049)
resource "aws_security_group_rule" "postgresql_efs_out" {
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.efs_sg.id
  security_group_id        = aws_security_group.postgresql_sg.id
  description              = "Allow NFS traffic to EFS"
}

# PostgreSQL Egress general (all outbound)
resource "aws_security_group_rule" "postgresql_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.postgresql_sg.id
  description       = "Allow all outbound traffic"
}


#############################
# EFS Security Group Rules
#############################

# EFS Ingress NFS from WordPress
resource "aws_security_group_rule" "efs_nfs_in_wordpress" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.wordpress_sg.id
  security_group_id        = aws_security_group.efs_sg.id
  description              = "Allow NFS traffic from WordPress"
}

# EFS Ingress NFS from PostgreSQL
resource "aws_security_group_rule" "efs_nfs_in_postgresql" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.postgresql_sg.id
  security_group_id        = aws_security_group.efs_sg.id
  description              = "Allow NFS traffic from PostgreSQL"
}

# EFS Egress general (all outbound)
resource "aws_security_group_rule" "efs_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs_sg.id
  description       = "Allow all outbound traffic"
}


#############################
# React Security Group Rules
#############################

# React Ingress HTTP from ALB
resource "aws_security_group_rule" "react_http_in" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.react_sg.id
  description              = "Allow HTTP traffic from ALB"
}

# React Ingress HTTPS from ALB
resource "aws_security_group_rule" "react_https_in" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.react_sg.id
  description              = "Allow HTTPS traffic from ALB"
}

# React Egress to NestJS backend (puerto 3000)
resource "aws_security_group_rule" "react_to_nestjs_out" {
  type              = "egress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.react_sg.id
  description       = "Allow React to access NestJS backend"
}

# React Egress general (all outbound)
resource "aws_security_group_rule" "react_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.react_sg.id
  description       = "Allow all outbound traffic from React"
}


#############################
# NestJS Security Group Rules
#############################

# NestJS Ingress from React (puerto 3000)
resource "aws_security_group_rule" "nestjs_in_from_react" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.react_sg.id
  security_group_id        = aws_security_group.nestjs_sg.id
  description              = "Allow NestJS backend to receive traffic from React"
}

# NestJS Egress to PostgreSQL (5432)
resource "aws_security_group_rule" "nestjs_to_postgres_out" {
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.nestjs_sg.id
  description       = "Allow NestJS backend to connect to PostgreSQL"
}

# NestJS Egress general (all outbound)
resource "aws_security_group_rule" "nestjs_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nestjs_sg.id
  description       = "Allow all outbound traffic from NestJS backend"
}
