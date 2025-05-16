resource "aws_ecs_service" "ndr_ecs_service" {
  count           = var.is_service_needed ? 1 : 0
  name            = var.ecs_cluster_service_name
  cluster         = aws_ecs_cluster.ndr_ecs_cluster.id
  task_definition = aws_ecs_task_definition.ndr_ecs_task.arn
  desired_count   = var.desired_count
  launch_type     = var.ecs_launch_type

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.ndr_ecs_sg.id]
    subnets          = [for subnet in var.private_subnets : subnet]
  }

  dynamic "load_balancer" {
    for_each = var.is_lb_needed ? toset([1]) : toset([])
    content {
      target_group_arn = aws_lb_target_group.ecs_lb_tg[0].arn
      container_name   = "${terraform.workspace}-container-${var.ecs_cluster_name}"
      container_port   = var.container_port
    }
  }

  tags = {
    Name        = "${terraform.workspace}-ecs"
    Environment = var.environment
    Workspace   = terraform.workspace
  }

  depends_on = [aws_lb_target_group.ecs_lb_tg[0]]

  lifecycle {
    ignore_changes = [ # The task definition is being modified outside of terraform, so we need to ignore it
      task_definition
    ]
  }
}

resource "aws_appautoscaling_target" "ndr_ecs_service_autoscale_target" {
  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "service/${aws_ecs_cluster.ndr_ecs_cluster.name}/${aws_ecs_service.ndr_ecs_service[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_cluster.ndr_ecs_cluster, aws_ecs_service.ndr_ecs_service[0]]

  tags = {
    Name        = "${terraform.workspace}-ecs-service-autoscale-target"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
  count = !var.is_autoscaling_needed ? 0 : 1

}

resource "aws_appautoscaling_policy" "ndr_ecs_service_autoscale_up" {
  name               = "${terraform.workspace}-${var.ecs_cluster_name}-${var.ecs_cluster_service_name}-autoscale-up-policy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ndr_ecs_service_autoscale_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ndr_ecs_service_autoscale_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ndr_ecs_service_autoscale_target[0].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 1
    }
  }
  count = local.is_sandbox || !var.is_autoscaling_needed ? 0 : 1
}

resource "aws_appautoscaling_policy" "ndr_ecs_service_autoscale_down" {
  name               = "${terraform.workspace}-${var.ecs_cluster_name}-${var.ecs_cluster_service_name}-autoscale-down-policy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ndr_ecs_service_autoscale_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ndr_ecs_service_autoscale_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ndr_ecs_service_autoscale_target[0].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
  count = local.is_sandbox || !var.is_autoscaling_needed ? 0 : 1
}
