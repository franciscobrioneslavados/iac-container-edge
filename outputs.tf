output "ecs_cluster_id" {
  description = "ECS cluster id (null si no creado)"
  value       = try(module.ecs_cluster.ecs_cluster_id, null)
}

output "password_database" {
  sensitive   = true
  description = "Database passwords used in the deployment"
  value = {
    mariadb_password_arn   = try(module.mariadb_service.database_password_arn, null)
    mariadb_password_plain = try(module.mariadb_service.database_password_plain, null)
  }
}

output "services_discovery_names_list" {
  description = "The names of the services registered in service discovery"
  value = {
    mariadb   = try(module.mariadb_service.service_name, null)
    wordpress = try(module.wordpress_service.service_name, null)
  }
}

output "services_discovery_ids_list" {
  description = "The IDs of the services registered in service discovery"
  value = {
    mariadb   = try(module.mariadb_service.service_id, null)
    wordpress = try(module.wordpress_service.service_id, null)
  }
}

output "services_discovery_arns_list" {
  description = "The ARNs of the services registered in service discovery"
  value = {
    mariadb   = try(module.services_discovery.service_arns["mariadb"], null)
    wordpress = try(module.services_discovery.service_arns["wordpress"], null)
  }
}

output "services_discovery_namespace" {
  description = "value"
  value       = try(module.services_discovery.namespace_name, null)
}

output "example_connexion_to_mariadb_from_wordpress" {
  description = "Example connexion string from WordPress to MariaDB"
  # should be maridb-service.container-edge-<env>.local:3306
  value = "mariadb-service.container-edge-${var.environment}.local:3306"
}
