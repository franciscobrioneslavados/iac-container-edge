resource "aws_lb" "main" {
  name                       = var.alb_name
  internal                   = var.alb_internal
  load_balancer_type         = "application"
  security_groups            = var.alb_security_groups
  subnets                    = var.alb_subnets
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "wordpress" {
  name        = var.wordpress_target_group_name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group" "react" {
  name        = var.react_target_group_name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "wordpress" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
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

resource "aws_lb_listener_rule" "react" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.react.arn
  }

  condition {
    host_header {
      values = ["app.${var.domain_name}"]
    }
  }
}
