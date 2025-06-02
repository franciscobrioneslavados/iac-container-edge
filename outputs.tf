output "services_discovery_names" {
  description = "Names of the service discovery services"
  value       = module.service_discovery.service_names
}

output "efs_configs" {
  value = {
    efs_postgresql = {
      efs_id            = module.efs_postgresql.efs_id
      efs_mount_targets = module.efs_postgresql.efs_mount_targets
    },
    efs_wordpress = {
      efs_id            = module.efs_wordpress.efs_id
      efs_mount_targets = module.efs_wordpress.efs_mount_targets
    }
  }
  description = "EFS configurations for PostgreSQL and WordPress"
}

output "ecs_services" {
  value = {
    postgresql = {
      service_id = module.postgresql_service.service_id
    },
    wordpress = {
      service_id = module.wordpress_service.service_id
    }
  }
  description = "ECS services configurations for PostgreSQL and WordPress"
}

