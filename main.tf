data "aws_vpc" "selected" {
  id = var.vpc_id
}

locals {
  global_tags = {
    "Environment" = var.environment
    "ManagedBy"   = var.managed_by
    "OwnerName"   = var.owner_name
    "ProjectName" = var.project_name
  }

  sd_services = {
    # Base de datos - A + SRV para descubrimiento automático de puerto
    mariadb = {
      name = "mariadb"
      dns_records = [
        {
          type = "A"
          ttl  = 10
        },
        {
          type = "SRV"
          ttl  = 10
        }
      ]
      routing_policy                 = "MULTIVALUE"
      health_check_failure_threshold = 1
    }

    # WordPress - A + SRV para descubrimiento automático de puerto 8080
    wordpress = {
      name = "wordpress"
      dns_records = [
        {
          type = "A"
          ttl  = 10
        },
        {
          type = "SRV"
          ttl  = 10
        }
      ]
      routing_policy                 = "MULTIVALUE"
      health_check_failure_threshold = 1
    }

    # Backend APIs - Solo A (puerto conocido en código)
    nestjs-backend = {
      name = "nestjs"
      dns_records = [
        {
          type = "A"
          ttl  = 10
        }
      ]
      routing_policy                 = "MULTIVALUE"
      health_check_failure_threshold = 1
    }

    python-analytics = {
      name = "python"
      dns_records = [
        {
          type = "A"
          ttl  = 10
        }
      ]
      routing_policy                 = "MULTIVALUE"
      health_check_failure_threshold = 1
    }

    # Frontends SPAs - Solo A (puerto conocido en NGINX)
    angular-frontend = {
      name = "angular"
      dns_records = [
        {
          type = "A"
          ttl  = 10
        }
      ]
      routing_policy                 = "MULTIVALUE"
      health_check_failure_threshold = 1
    }

    react-frontend = {
      name = "react"
      dns_records = [
        {
          type = "A"
          ttl  = 10
        }
      ]
      routing_policy                 = "MULTIVALUE"
      health_check_failure_threshold = 1
    }
  }

  vpc_dns_resolver = cidrhost(data.aws_vpc.selected.cidr_block, 2)
}

module "services_discovery" {
  source = "./modules/services_discovery/private"

  vpc_id         = var.vpc_id
  services       = local.sd_services
  namespace_name = var.namespace_name

  global_tags = local.global_tags
}

module "security_groups" {
  source = "./modules/segurity_groups"

  vpc_id      = var.vpc_id
  cidr_blocks = var.cidr_blocks
  global_tags = local.global_tags
}

module "ecs_cluster" {
  source = "./modules/ecs_cluster"

  namespace_name = module.services_discovery.namespace_arn
  global_tags    = local.global_tags
}

module "efs_mariadb" {
  source = "./modules/storage/efs"

  deploy_efs         = var.environment == "production" ? true : false
  efs_name           = "mariadb"
  efs_purpose        = "Database"
  private_subnet_ids = var.private_subnet_ids
  security_groups    = [module.security_groups.efs_security_group_id]
  global_tags        = local.global_tags
}

module "efs_wordpress" {
  source = "./modules/storage/efs"

  deploy_efs         = var.environment == "production" ? true : false
  efs_name           = "wordpress"
  efs_purpose        = "Storage"
  private_subnet_ids = var.private_subnet_ids
  security_groups    = [module.security_groups.efs_security_group_id]
  global_tags        = local.global_tags
}

module "mariadb_service" {
  source = "./modules/ecs_services/mariadb"

  deploy_efs = var.environment == "production" ? true : false
  efs_id     = var.environment == "production" ? module.efs_mariadb.efs_id : null

  ecs_cluster_id = module.ecs_cluster.ecs_cluster_id
  desired_count  = 1

  subnet_ids            = var.private_subnet_ids
  security_group_ids    = [module.security_groups.ecs_security_group_ids["mariadb"]]
  execution_role_arn    = aws_iam_role.ecs_task_execution.arn
  task_role_arn         = aws_iam_role.ecs_task.arn
  discovery_service_arn = module.services_discovery.service_arns["mariadb"]

  global_tags = local.global_tags
  depends_on  = [module.services_discovery]
}

module "wordpress_service" {
  source = "./modules/ecs_services/wordpress"

  deploy_efs = var.environment == "production" ? true : false
  efs_id     = var.environment == "production" ? module.efs_wordpress.efs_id : null

  ecs_cluster_id = module.ecs_cluster.ecs_cluster_id
  desired_count  = 1

  subnet_ids               = var.private_subnet_ids
  security_group_ids       = [module.security_groups.ecs_security_group_ids["wordpress"]]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  database_password_plain  = module.mariadb_service.database_password_plain
  database_password_arn    = module.mariadb_service.database_password_arn
  mariadb_service_endpoint = "${module.services_discovery.service_names["mariadb"]}.${var.namespace_name}"
  discovery_service_arn    = module.services_discovery.service_arns["wordpress"]

  global_tags = local.global_tags
  depends_on  = [module.services_discovery]
}
