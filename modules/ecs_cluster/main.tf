
locals {
  ecs_cluster_name = "ecs-${var.global_tags["ProjectName"]}-${var.global_tags["Environment"]}-cluster"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${local.ecs_cluster_name}"
  retention_in_days = var.global_tags["Environment"] == "production" ? 30 : 7
}

resource "aws_ecs_cluster" "main" {
  name = local.ecs_cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.this.name
      }
    }
  }

  service_connect_defaults {
    namespace = var.namespace_name
  }

  tags = merge(var.global_tags, {
    Name = local.ecs_cluster_name
  })
}
