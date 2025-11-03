# Execution Role - Para que ECS pueda manejar el task
resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.global_tags["ProjectName"]}-${local.global_tags["Environment"]}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

}

# Task Role - Para que los contenedores accedan a AWS servicios
resource "aws_iam_role" "ecs_task" {
  name = "${local.global_tags["ProjectName"]}-${local.global_tags["Environment"]}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

}

# Policy Attachment para Execution Role (ECS para manejar tasks)
resource "aws_iam_role_policy_attachment" "ecs_execution_managed" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Policy Attachment para EFS (Task Role)
resource "aws_iam_role_policy_attachment" "ecs_efs_access" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
}

# Policy personalizada para Task Role (contenedores acceden a servicios AWS)
resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "${local.global_tags["ProjectName"]}-${local.global_tags["Environment"]}-ecs-task-policy"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${local.global_tags["ProjectName"]}-${local.global_tags["Environment"]}-*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

# Policy para ECS Exec (debugging)
resource "aws_iam_role_policy_attachment" "ecs_task_ssm" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
