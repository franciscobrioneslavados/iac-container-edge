resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = var.namespace_name
  description = "Private DNS namespace for ECS services"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "this" {
  for_each = toset(var.discovery_service_name)
  name     = each.value

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
