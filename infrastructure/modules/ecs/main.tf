resource "aws_ecs_task_definition" "ndr_ecs_task" {
  family                   = "${terraform.workspace}-task-${var.ecs_cluster_name}"
  execution_role_arn       = aws_iam_role.task_exec.arn
  task_role_arn            = var.task_role
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_definition_cpu
  memory                   = var.ecs_task_definition_memory
  track_latest             = true # ECS tasks are also being modified by the UI deployment pipeline

  container_definitions = jsonencode([
    {
      name        = "${terraform.workspace}-container-${var.ecs_cluster_name}"
      image       = var.ecr_repository_url
      cpu         = var.ecs_container_definition_cpu
      memory      = var.ecs_container_definition_memory
      readonlyRootFilesystem = true
      essential   = true
      networkMode = "awsvpc"
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
      }]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group" : aws_cloudwatch_log_group.awslogs-ndr-ecs.name,
          "awslogs-region" : var.aws_region,
          "awslogs-create-group" : "true",
          "awslogs-stream-prefix" : terraform.workspace
        }
      }
      environment = var.environment_vars
    }
  ])
}

resource "aws_cloudwatch_log_group" "awslogs-ndr-ecs" {
  name              = "${terraform.workspace}-ecs-task-${var.ecs_cluster_name}"
  retention_in_days = 0
}
