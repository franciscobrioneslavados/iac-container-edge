
# S3 Bucket for ALB Access Logs
resource "aws_s3_bucket" "alb_logs" {
  count         = var.enable_access_logs ? 1 : 0
  bucket        = "${var.global_tags["Project"]}-${var.global_tags["Environment"]}-alb-logs-${random_id.bucket_suffix.hex}"
  force_destroy = var.global_tags["Environment"] != "prod"

  tags = merge(var.global_tags, {
    "Name" = "${var.global_tags["Project"]}-${var.global_tags["Environment"]}-alb-logs"
  })
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "alb_logs" {
  count  = var.enable_access_logs ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  count  = var.enable_access_logs ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  count  = var.enable_access_logs ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[0].id

  rule {
    id     = "log_retention"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }
    expiration {
      days = var.global_tags["Environment"] == "prod" ? 90 : 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

# ALB Logs Bucket Policy
data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "alb_logs" {
  count  = var.enable_access_logs ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs[0].arn}/alb/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs[0].arn}/alb/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.alb_logs[0].arn
      }
    ]
  })
}

# ALB principal
resource "aws_lb" "main" {
  name                       = var.alb_name
  internal                   = var.alb_internal
  load_balancer_type         = "application"
  security_groups            = var.alb_security_groups
  subnets                    = var.alb_subnets
  enable_deletion_protection = var.global_tags["Environment"] == "production"

  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = aws_s3_bucket.alb_logs[0].bucket
      prefix  = "alb"
      enabled = true
    }
  }

  tags = merge(var.global_tags, {
    Name = var.alb_name
  })
}

# Target group para WordPress
resource "aws_lb_target_group" "wordpress_tg" {
  name        = var.wordpress_target_group_name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/wp-admin/admin-ajax.php"
    matcher             = "200,302"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }

  tags = merge(var.global_tags, {
    Name = var.wordpress_target_group_name
  })
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_tg.arn
  }
}

# HTTP Listener (Redirect to HTTPS)
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# WAF Web ACL
resource "aws_wafv2_web_acl" "wordpress" {
  count       = var.enable_waf ? 1 : 0
  name        = "waf-${var.global_tags["Project"]}-${var.global_tags["Environment"]}"
  description = "WAF for ${var.global_tags["Project"]} in ${var.global_tags["Environment"]}"
  scope       = "REGIONAL"

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WordPressWAF"
    sampled_requests_enabled   = true
  }

  default_action {
    allow {}
  }

  # Rate Limiting Rule
  rule {
    name     = "RateLimitRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # WordPress Specific Rules
  rule {
    name     = "AWSManagedRulesWordPressRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesWordPressRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "WordPressRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  tags = merge(var.global_tags, {
    Name = "waf-${var.global_tags["Project"]}-${var.global_tags["Environment"]}"
  })
}

resource "aws_wafv2_web_acl_association" "wordpress" {
  count        = var.enable_waf ? 1 : 0
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.wordpress[0].arn
}
