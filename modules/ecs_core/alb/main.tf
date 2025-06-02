# ALB principal
resource "aws_lb" "main" {
  name                       = var.alb_name
  internal                   = var.alb_internal
  load_balancer_type         = "application"
  security_groups            = var.alb_security_groups
  subnets                    = var.alb_subnets
  enable_deletion_protection = false
}

# Target group para WordPress
resource "aws_lb_target_group" "wordpress_tg" {
  name        = var.wordpress_target_group_name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Target group para ReactJS
resource "aws_lb_target_group" "react_tg" {
  name        = var.react_target_group_name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Listener único (puerto 80) con respuesta por defecto 404
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_tg.arn
  }
}

# Regla para enrutar tráfico hacia WordPress
resource "aws_lb_listener_rule" "wordpress_listener" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_tg.arn
  }

  condition {
    host_header {
      values = [
        var.domain_name,
        "www.${var.domain_name}",
      ]
    }
  }
}

# Regla para enrutar tráfico hacia React
resource "aws_lb_listener_rule" "react_listener" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.react_tg.arn
  }

  condition {
    host_header {
      values = ["app.${var.domain_name}"]
    }
  }
}
