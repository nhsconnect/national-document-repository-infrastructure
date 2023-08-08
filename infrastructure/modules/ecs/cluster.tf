resource "aws_ecs_cluster" "ndr_esc_cluster" {
  name = var.ecs_cluster_name

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_cluster_logs.name
      }
    }
  }

  tags = {
    Name = "${terraform.workspace}-ecs"
    #   Environment = var.environment
    Workspace = terraform.workspace
  }
}

resource "aws_cloudwatch_log_group" "ecs_cluster_logs" {
  name = "${var.ecs_cluster_name}-logs"
}