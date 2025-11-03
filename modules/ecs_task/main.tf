resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.global_tags["ProjectName"]}/${var.global_tags["Environment"]}/${var.service_name}"
  retention_in_days = var.global_tags["Environment"] == "production" ? 30 : 7

  tags = merge(var.global_tags, {
    Name = "${var.service_name}-logs"
  })
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.global_tags["ProjectName"]}-${var.global_tags["Environment"]}-${var.service_name}"
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([merge(
    {
      name      = var.service_name
      image     = var.service_config.image
      essential = var.essential

      # Port mappings
      portMappings = [
        for port_map in lookup(var.service_config, "port_mappings", []) : {
          containerPort = port_map.container_port
          hostPort      = port_map.host_port
          protocol      = lookup(port_map, "protocol", "tcp")
        }
      ]

      # Environment variables
      environment = [
        for k, v in lookup(var.service_config, "environment", {}) : { name = k, value = v }
      ]

      # Secrets
      secrets = [
        for k, v in lookup(var.service_config, "secrets", {}) : { name = k, valueFrom = v }
      ]

      # Mount points
      mountPoints = [
        for mp in lookup(var.service_config, "mount_points", []) : {
          sourceVolume  = mp.source_volume
          containerPath = mp.container_path
          readOnly      = mp.read_only
        }
      ]

      # Log configuration (default o custom)
      logConfiguration = lookup(var.service_config, "log_configuration", null) != null ? {
        logDriver = var.service_config.log_configuration.log_driver
        options   = var.service_config.log_configuration.options
        } : {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = "us-east-1" #TODO: make dynamic
          "awslogs-stream-prefix" = "ecs"
        }
      }
    },
    # Optional configurations
    lookup(var.service_config, "health_check", null) != null ? {
      healthCheck = {
        command     = var.service_config.health_check.command
        interval    = var.service_config.health_check.interval
        timeout     = var.service_config.health_check.timeout
        retries     = var.service_config.health_check.retries
        startPeriod = var.service_config.health_check.startPeriod
      }
    } : {},
    length(lookup(var.service_config, "entry_point", [])) > 0 ? {
      entryPoint = var.service_config.entry_point
    } : {},
    length(lookup(var.service_config, "command", [])) > 0 ? {
      command = var.service_config.command
    } : {},
    lookup(var.service_config, "working_directory", null) != null ? {
      workingDirectory = var.service_config.working_directory
    } : {},
    lookup(var.service_config, "linux_parameters", null) != null ? {
      linuxParameters = {
        capabilities = {
          add  = lookup(var.service_config.linux_parameters.capabilities, "add", [])
          drop = lookup(var.service_config.linux_parameters.capabilities, "drop", [])
        }
      }
    } : {},
    length(lookup(var.service_config, "depends_on", [])) > 0 ? {
      dependsOn = [
        for dep in var.service_config.depends_on : {
          containerName = dep.container_name
          condition     = dep.condition
        }
      ]
    } : {}
  )])

  # Dynamic volumes SOLO para EFS (Fargate no soporta host volumes)
  dynamic "volume" {
    for_each = lookup(var.service_config, "volumes", [])

    # FILTRAR: Solo procesar volumes que tengan efs_id (EFS volumes)
    content {
      name = volume.value.name

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_id != null ? [1] : []
        content {
          file_system_id          = volume.value.efs_id
          root_directory          = lookup(volume.value, "root_directory", "/")
          transit_encryption      = lookup(volume.value, "transit_encryption", "ENABLED")
          transit_encryption_port = lookup(volume.value, "transit_encryption_port", null)
        }
      }
    }
  }
  tags = merge(var.global_tags, {
    Name = "${var.service_name}-task-definition"
  })
}
