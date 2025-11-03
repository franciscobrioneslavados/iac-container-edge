# modules/service-discovery/main.tf
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = var.namespace_name
  description = "Private DNS namespace for ECS services"
  vpc         = var.vpc_id

  tags = merge(var.global_tags, {
    "SD Private DNS Name" = var.namespace_name
  })
}

resource "aws_service_discovery_service" "this" {
  for_each = var.services

  name = each.value.name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    # Soporta múltiples registros DNS
    dynamic "dns_records" {
      for_each = lookup(each.value, "dns_records", [
        {
          type = lookup(each.value, "dns_type", "A")
          ttl  = lookup(each.value, "ttl", 10)
        }
      ])

      content {
        type = dns_records.value.type
        ttl  = dns_records.value.ttl
      }
    }

    routing_policy = lookup(each.value, "routing_policy", "MULTIVALUE")
  }

  # Solo para registros A, AAAA, CNAME, y SRV
  dynamic "health_check_custom_config" {
    for_each = contains(["A", "AAAA", "CNAME", "SRV"], lookup(each.value, "dns_type", "A")) ? [1] : []

    content {
      failure_threshold = lookup(each.value, "health_check_failure_threshold", 1)
    }
  }

  lifecycle {
    ignore_changes = [dns_config, health_check_custom_config]
  }

  tags = merge(var.global_tags, {
    "SD Service" = each.value.name
  })
}