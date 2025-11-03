locals {
  # Configuración de seguridad por ambiente
  security_config = {
    development = {
      use_kms         = false
      password_length = 12
      enable_rotation = false
      use_secret_mgr  = false
    }
    staging = {
      use_kms         = true
      password_length = 16
      enable_rotation = true
      use_secret_mgr  = true
    }
    production = {
      use_kms         = true
      password_length = 16
      enable_rotation = true
      use_secret_mgr  = true
    }
  }

  current_security_config = local.security_config[var.global_tags["Environment"]]
  should_use_kms          = local.current_security_config.use_kms
  should_use_secret_mgr   = local.current_security_config.use_secret_mgr
}


resource "random_password" "mariadb_dev" {
  length  = local.current_security_config.password_length
  special = false
  count   = local.should_use_secret_mgr ? 0 : 1
}


module "mariadb_secret" {
  source = "../../secret_manager"
  count  = local.should_use_secret_mgr ? 1 : 0

  secret_name = "${var.global_tags["ProjectName"]}-${var.global_tags["Environment"]}-mariadb-password"
  description = "Contraseña de MariaDB para ${var.global_tags["ProjectName"]}-${var.global_tags["Environment"]}"
  global_tags = var.global_tags

  password_length       = local.current_security_config.password_length
  include_special_chars = false
  enable_rotation       = local.current_security_config.enable_rotation

  kms_key_id     = local.should_use_kms ? var.kms_key_id : null
  create_kms_key = false
}

locals {
  mariadb_password = local.should_use_secret_mgr ? module.mariadb_secret[0].secret_arn : random_password.mariadb_dev[0].result
}

module "mariadb_task" {
  source = "../../ecs_task"

  service_name             = "mariadb"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  global_tags              = var.global_tags
  service_config = {
    name  = "mariadb"
    image = "public.ecr.aws/bitnami/mariadb:latest"

    port_mappings = [
      {
        container_port = 3306
        host_port      = 3306
        protocol       = "tcp"
      }
    ]

    environment = local.should_use_secret_mgr ? {
      ALLOW_EMPTY_PASSWORD = "no"
      MARIADB_DATABASE     = "wordpress"
      MARIADB_USER         = "wp_user"
      } : {
      MARIADB_ROOT_PASSWORD = local.mariadb_password
      MARIADB_DATABASE      = "wordpress"
      MARIADB_USER          = "wp_user"
      MARIADB_PASSWORD      = local.mariadb_password
    }

    secrets = local.should_use_secret_mgr ? {
      MARIADB_ROOT_PASSWORD = local.mariadb_password
      MARIADB_PASSWORD      = local.mariadb_password
    } : null

    volumes = var.deploy_efs && var.efs_id != null ? [
      {
        name              = "mariadb-data"
        efs_id            = var.efs_id
        rootDirectory     = "/mariadb",
        transitEncryption = "ENABLED"

      }
    ] : []

    mount_points = var.deploy_efs && var.efs_id != null ? [
      {
        source_volume  = "mariadb-data"
        container_path = "/mariadb"
        # read_only      = false
      }
    ] : []

    health_check = {
      command     = ["CMD-SHELL", "mysqladmin ping -h 127.0.0.1 -u root -p$MARIADB_ROOT_PASSWORD || exit 1"],
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }
  }
}

resource "aws_ecs_service" "mariadb" {
  name            = "mariadb"
  cluster         = var.ecs_cluster_id
  task_definition = module.mariadb_task.ecs_task_definition_arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = var.discovery_service_arn
    port         = 3306
  }

  deployment_controller {
    type = "ECS"
  }

  # ordered_placement_strategy {
  #   type  = "spread"
  #   field = "attribute:ecs.availability-zone"
  # }

  health_check_grace_period_seconds = var.global_tags["Environment"] == "production" ? 120 : 60
  enable_execute_command            = var.global_tags["Environment"] != "production"


  tags = merge(var.global_tags, {
    Name = "mariadb"
    Type = "database"
  })

  depends_on = [module.mariadb_task]
}
