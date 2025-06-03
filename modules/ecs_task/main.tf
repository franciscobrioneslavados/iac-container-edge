resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.global_tags["Project"]}/${var.global_tags["Environment"]}/${var.service_name}"
  retention_in_days = var.global_tags["Environment"] == "production" ? 30 : 7
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.service_name}-family"
  network_mode             = var.network_mode != null ? var.network_mode : "awsvpc"
  requires_compatibilities = var.requires_compatibilities != null ? var.requires_compatibilities : ["FARGATE"]
  cpu                      = var.cpu != null ? var.cpu : "256"
  memory                   = var.memory != null ? var.memory : "512"
  execution_role_arn       = var.execution_role_arn # IAM role for task execution
  # task_role_arn           = var.task_role_arn # IAM role for task permissions

  container_definitions = jsonencode([{
    name  = var.service_name,
    image = var.service_config.image,
    portMappings = [
      for port_map in var.service_config.port_mappings : {
        containerPort = port_map.container_port
        hostPort      = port_map.host_port
        protocol      = lookup(port_map, "protocol", "tcp")
      }
    ],
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.this.name
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
    environment = [
      for k, v in lookup(var.service_config, "environment", {}) : { name = k, value = v }
    ],
    secrets = [
      for k, v in lookup(var.service_config, "secrets", {}) : { name = k, valueFrom = v }
    ],
    mountPoints = [
      for vol in lookup(var.service_config, "volumes", []) : {
        sourceVolume  = vol.name,
        containerPath = vol.host_path != null ? vol.host_path : "/data/${vol.name}",
        readOnly      = false
      }
    ]
  }])

  dynamic "volume" {
    for_each = lookup(var.service_config, "volumes", [])
    content {
      name = volume.value.name
      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_id != null ? [1] : []
        content {
          file_system_id     = volume.value.efs_id
          root_directory     = volume.value.root_directory
          transit_encryption = "ENABLED"
        }
      }
    }
  }
}
