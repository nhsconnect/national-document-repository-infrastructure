output "dns_name" {
  value = var.is_lb_needed ? aws_lb.ecs_lb[0].dns_name : null
}

output "security_group_id" {
  value = aws_security_group.ndr_ecs_sg.id
}

output "load_balancer_arn" {
  description = "The arn of the load balancer"
  value       = var.is_lb_needed ? aws_lb.ecs_lb[0].arn : null
}

output "certificate_arn" {
  description = "The arn of certificate that load balancer is using"
  value       = var.is_lb_needed ? data.aws_acm_certificate.amazon_issued[0].arn : null
}

output "container_port" {
  description = "The container port number of docker image, which was provided as input variable of this module"
  value       = var.container_port
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.ndr_ecs_cluster.arn
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.ndr_ecs_task.arn_without_revision
}