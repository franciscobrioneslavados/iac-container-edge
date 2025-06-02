resource "aws_ecs_cluster" "main" {
  name = "ecs-${var.project}-${var.environment}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}