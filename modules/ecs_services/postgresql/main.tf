module "postgresql_task" {
  source = "../../ecs_task"

  service_name             = "postgresql"
  execution_role_arn       = var.execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  global_tags              = var.global_tags
  service_config = {
    image = "postgres:17"
    port_mappings = [
      {
        container_port = 5432
        host_port      = 5432
        protocol       = "tcp"
      }
    ]
    environment = {
      POSTGRES_USER     = "wordpress"
      POSTGRES_PASSWORD = "${var.global_tags["Environment"]}.wordpress"
      POSTGRES_DB       = "wordpress"
    }
    secrets = {}
    volumes = [
      {
        name      = "postgresql-data"
        host_path = null
        efs_id    = var.efs_id
      }
    ]
  }
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
    registry_arn = var.registry_arn
  }

  depends_on = [module.postgresql_task]
}