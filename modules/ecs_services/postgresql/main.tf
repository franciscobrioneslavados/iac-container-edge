locals {
  # Determinar si usar KMS basado en ambiente (si no se especificó explícitamente)
  should_use_kms = var.use_kms_encryption != null ? var.use_kms_encryption : (
    var.global_tags["Environment"] == "production" ? true : false
  )

  # Configuración de seguridad por ambiente
  security_config = {
    development = {
      use_kms         = false
      password_length = 12
      enable_rotation = false
    }
    staging = {
      use_kms         = false
      password_length = 16
      enable_rotation = true
    }
    production = {
      use_kms         = true
      password_length = 16
      enable_rotation = true
    }
  }

  current_security_config = local.security_config[var.global_tags["Environment"]]
}

resource "random_string" "random" {
  length  = 6
  special = false
}


# Módulo de secret para PostgreSQL
module "postgresql_secret" {
  source = "../../secret_manager"
  count  = var.create_database_secret ? 1 : 0

  secret_name = "${var.global_tags["ProjectName"]}-${var.global_tags["Environment"]}-postgresql-password-${random_string.random.result}" # Añadir sufijo random para evitar colisiones
  global_tags = var.global_tags
  description = "Contraseña de PostgreSQL para ${var.global_tags["ProjectName"]}-${var.global_tags["Environment"]}"

  # Configuración basada en ambiente
  password_length       = local.current_security_config.password_length
  include_special_chars = false # PostgreSQL funciona mejor sin caracteres especiales
  enable_rotation       = local.current_security_config.enable_rotation

  # KMS configuration
  kms_key_id     = local.should_use_kms ? var.kms_key_id : null
  create_kms_key = false # No crear KMS key aquí, usar una central si es necesario
}

# Local para determinar qué ARN usar
locals {
  final_database_password_arn = var.create_database_secret ? (
    module.postgresql_secret[0].secret_arn
  ) : var.database_password_arn

  # Validar que tenemos un ARN válido
  has_valid_secret = local.final_database_password_arn != null
}

module "postgresql_task" {
  source = "../../ecs_task"

  service_name             = "postgresql"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  global_tags              = var.global_tags
  service_config = {
    image = "613608381466.dkr.ecr.us-east-1.amazonaws.com/default/custom-postgresql-for-wordpress-ecs:latest"
    # entryPoint = ["/entrypoint.sh"]
    port_mappings = [
      {
        container_port = 5432
        host_port      = 5432
      }
    ]

    environment = {
      POSTGRES_USER = "wordpress"
      POSTGRES_DB   = "wordpress"
    }

    secrets = local.has_valid_secret ? {
      POSTGRES_PASSWORD = local.final_database_password_arn
    } : null

    volumes = var.deploy_efs && var.efs_id != null ? [
      {
        name           = "postgresql-data"
        efs_id         = var.efs_id
        root_directory = "/"
      }
    ] : []

    mount_points = var.deploy_efs && var.efs_id != null ? [
      {
        source_volume  = "postgresql-data"
        container_path = "/var/lib/postgresql/data"
        read_only      = false
      }
    ] : []

    health_check = {
      command     = ["CMD-SHELL", "pg_isready -U wordpress || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }

    # PostgreSQL específico
    command = ["postgres", "-c", "shared_preload_libraries=pg_stat_statements"]
  }
}

data "aws_service_discovery_service" "this" {
  name         = "postgresql"
  namespace_id = var.discovery_service_id
}

resource "aws_ecs_service" "postgresql" {
  name            = "postgresql"
  cluster         = var.ecs_cluster_id
  task_definition = module.postgresql_task.ecs_task_definition_arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = data.aws_service_discovery_service.this.arn
    port         = 5432
  }


  lifecycle {
    ignore_changes = [
      desired_count,   # Evita que Terraform modifique el count
      task_definition, # Evita recreación por cambios en task definition
    ]
  }

  deployment_controller {
    type = "ECS"
  }

  # ordered_placement_strategy {
  #   type  = "spread"
  #   field = "attribute:ecs.availability-zone"
  # }

  health_check_grace_period_seconds = var.global_tags["Environment"] == "production" ? 120 : 60

  enable_execute_command = var.global_tags["Environment"] != "production" # Solo en dev/staging

  tags = merge(var.global_tags, {
    Name = "postgresql-service"
    Type = "database"
  })

  depends_on = [module.postgresql_task]
}
