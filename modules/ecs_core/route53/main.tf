# Health Check
resource "aws_route53_health_check" "primary" {
  count             = var.enable_failover ? 1 : 0
  fqdn              = var.domain_name
  port              = 443
  type              = "HTTPS_STR_MATCH"
  resource_path     = "/wp-includes/js/heartbeat.min.js"
  failure_threshold = "3"
  request_interval  = "30"
  measure_latency   = true
  search_string     = "heartbeat"

  tags = merge(var.global_tags, {
    Name = "${var.domain_name}-health-check-primary"
  })
}

# Primary DNS Record (with failover)
resource "aws_route53_record" "primary" {
  count   = var.enable_failover ? 1 : 0
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  set_identifier = "primary"

  failover_routing_policy {
    type = "PRIMARY"
  }

  health_check_id = aws_route53_health_check.primary[0].id

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Secondary DNS Record (failover)
resource "aws_route53_record" "secondary" {
  count   = var.enable_failover && var.secondary_alb_dns_name != "" ? 1 : 0
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  set_identifier = "secondary"

  failover_routing_policy {
    type = "SECONDARY"
  }

  alias {
    name                   = var.secondary_alb_dns_name
    zone_id                = var.secondary_alb_zone_id
    evaluate_target_health = true
  }
}

# Simple DNS Record (when failover is disabled)
resource "aws_route53_record" "simple" {
  count   = var.enable_failover ? 0 : 1
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# WWW Redirect
resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}