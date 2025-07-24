resource "aws_cloudwatch_metric_alarm" "alb_alarm_4XX" {
  count               = !local.is_sandbox && var.is_lb_needed ? 1 : 0
  alarm_name          = "4XX-status-${aws_lb.ecs_lb[0].name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_4XX_Count"
  period              = 60
  statistic           = "Sum"
  threshold           = 20
  treat_missing_data  = "notBreaching"
  dimensions = {
    LoadBalancer = aws_lb.ecs_lb[0].arn_suffix
  }
  alarm_description = "This alarm indicates that at least 20 4XX statuses have occurred on ${aws_lb.ecs_lb[0].name} in a minute."
  alarm_actions     = var.alarm_actions_arn_list

  tags = {
    Name = "4XX-status-${aws_lb.ecs_lb[0].name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_alarm_5XX" {
  alarm_name          = "5XX-status-${aws_lb.ecs_lb[0].name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  treat_missing_data  = "notBreaching"
  dimensions = {
    LoadBalancer = aws_lb.ecs_lb[0].arn_suffix
  }
  alarm_description = "This alarm indicates that at least 5 5XX statuses have occurred on ${aws_lb.ecs_lb[0].name} within 5 minutes."
  alarm_actions     = var.alarm_actions_arn_list

  tags = {
    Name = "5XX-status-${aws_lb.ecs_lb[0].name}"
  }
  count = !local.is_sandbox && var.is_lb_needed ? 1 : 0
}

resource "aws_cloudwatch_metric_alarm" "ndr_ecs_service_cpu_high_alarm" {
  alarm_name          = "${var.ecs_cluster_service_name}-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  period              = 60
  statistic           = "Average"
  threshold           = 85

  dimensions = {
    ClusterName = aws_ecs_cluster.ndr_ecs_cluster.name
    ServiceName = aws_ecs_service.ndr_ecs_service[0].name
  }

  alarm_description = "The CPU usage for ${var.ecs_cluster_service_name} is currently above 85%, the autoscaling will begin scaling up."
  alarm_actions     = concat(var.alarm_actions_arn_list, [aws_appautoscaling_policy.ndr_ecs_service_autoscale_up[0].arn])

  tags = {
    Name = "${var.ecs_cluster_service_name}-cpu-utilization-high"
  }
  count = local.is_sandbox || !var.is_service_needed ? 0 : 1
}

resource "aws_cloudwatch_metric_alarm" "ndr_ecs_service_cpu_low_alarm" {
  alarm_name          = "${var.ecs_cluster_service_name}-cpu-utilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  period              = 60
  statistic           = "Average"
  threshold           = 15

  dimensions = {
    ClusterName = aws_ecs_cluster.ndr_ecs_cluster.name
    ServiceName = aws_ecs_service.ndr_ecs_service[0].name
  }

  alarm_description = "The CPU usage for ${var.ecs_cluster_service_name} is currently belowe 15%, the autoscaling will begin scaling down."
  alarm_actions     = concat(var.alarm_actions_arn_list, [aws_appautoscaling_policy.ndr_ecs_service_autoscale_down[0].arn])

  tags = {
    Name = "${var.ecs_cluster_service_name}-cpu-utilization-low"
  }
  count = local.is_sandbox || !var.is_service_needed ? 0 : 1
}

