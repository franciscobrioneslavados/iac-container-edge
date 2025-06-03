module "wordpress_task" {
  source = "../../ecs_task"

  service_name             = "wordpress"
  execution_role_arn       = var.execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  global_tags              = var.global_tags
  service_config = {
    image = "wordpress:6"
    port_mappings = [
      {
        container_port = 80
        host_port      = 80
        protocol       = "tcp"
      }
    ]
    environment = {
      WORDPRESS_DB_HOST     = "postgresql.local:5432"
      WORDPRESS_DB_USER     = "wordpress"
      WORDPRESS_DB_PASSWORD = "${var.global_tags["Environment"]}.wordpress"
      WORDPRESS_DB_NAME     = "wordpress"
    }
    secrets = {}
    volumes = [
      {
        name      = "wordpress-data"
        host_path = null
        efs_id    = var.efs_id
      }
    ]
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

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "wordpress"
    container_port   = 80
  }

  service_registries {
    registry_arn = var.registry_arn
  }

  depends_on = [module.wordpress_task]
}
