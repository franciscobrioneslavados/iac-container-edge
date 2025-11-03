locals {

  # ¿Usamos Secret Manager?
  use_secret_mgr = var.database_password_arn != null

  # Environment variables siempre presentes
  wordpress_env = {
    WORDPRESS_DATABASE_HOST           = var.mariadb_service_endpoint # "mariadb.container-edge-development.local:3306" # TODO: parametrizar con service discovery output
    WORDPRESS_DATABASE_PORT_NUMBER    = "3306"
    WORDPRESS_DATABASE_NAME           = "wordpress"
    WORDPRESS_DATABASE_USER           = "wp_user"
    WORDPRESS_EXTRA_WP_CONFIG_CONTENT = "define('WP_HOME', 'http://' . $_SERVER['HTTP_HOST'] . '/wordpress');\ndefine('WP_SITEURL', 'http://' . $_SERVER['HTTP_HOST'] . '/wordpress');"
    WORDPRESS_ENABLE_REVERSE_PROXY    = "yes"
    WORDPRESS_ENABLE_HTTPS            = "no"
    WORDPRESS_SKIP_BOOTSTRAP          = "no"
    WORDPRESS_BLOG_NAME               = "Mi WordPress"
    ALLOW_EMPTY_PASSWORD              = "no"
  }

  # Secrets solo si existe ARN
  wordpress_secrets = local.use_secret_mgr ? {
    WORDPRESS_DATABASE_PASSWORD = var.database_password_arn
  } : null

  # Si no hay Secret Manager, inyectamos password directamente en environment
  wordpress_env_final = local.use_secret_mgr ? local.wordpress_env : merge(local.wordpress_env, {
    WORDPRESS_DATABASE_PASSWORD = var.database_password_plain
  })
}


module "wordpress_task" {
  source = "../../ecs_task"

  service_name             = "wordpress"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  global_tags              = var.global_tags

  service_config = {
    name  = "wordpress"
    image = "public.ecr.aws/bitnami/wordpress:latest"

    port_mappings = [
      {
        container_port = 8080
        host_port      = 8080
        protocol       = "tcp"
      },
      {
        container_port = 8443
        host_port      = 8443
        protocol       = "tcp"
      }
    ]

    environment = local.wordpress_env_final
    secrets     = local.wordpress_secrets

    health_check = {
      command      = ["CMD-SHELL", "php -r \"exit(file_get_contents('http://localhost:8080/') === false ? 1 : 0);\" || exit 1"]
      interval     = 30
      timeout      = 5
      retries      = 3
      start_period = 10
    }

    volumes = var.deploy_efs && var.efs_id != null ? [
      {
        name              = "wordpress-data"
        efs_id            = var.efs_id
        rootDirectory     = "/wordpress"
        transitEncryption = "ENABLED"
      }
    ] : []

    mount_points = var.deploy_efs && var.efs_id != null ? [
      {
        source_volume  = "wordpress-data"
        container_path = "/wordpress"
        read_only      = false
      }
    ] : []
  }
}

resource "aws_ecs_service" "wordpress" {
  name            = "wordpress"
  cluster         = var.ecs_cluster_id
  task_definition = module.wordpress_task.ecs_task_definition_arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = var.discovery_service_arn
    port         = 8080
  }

  deployment_controller {
    type = "ECS"
  }

  health_check_grace_period_seconds = var.global_tags["Environment"] == "production" ? 120 : 60
  enable_execute_command            = var.global_tags["Environment"] != "production"

  tags = merge(var.global_tags, {
    Name = "wordpress"
    Type = "WEB APP"
  })

  depends_on = [
    module.wordpress_task,
  ]
}
