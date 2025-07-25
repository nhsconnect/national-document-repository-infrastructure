variable "vpc_id" {
  description = "ID of the VPC to deploy into."
  type        = string
}

variable "sg_name" {
  description = "Name for the security group."
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster to deploy into."
  type        = string
}

variable "ecs_cluster_service_name" {
  description = "Name of the ECS service inside the cluster."
  type        = string
}

variable "ecs_launch_type" {
  description = "ECS launch type (e.g., FARGATE or EC2)."
  type        = string
  default     = "FARGATE"
}

variable "public_subnets" {
  description = "List of public subnet IDs."
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs."
  type        = list(string)
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "environment" {
  description = "Deployment environment tag used for naming and labeling (e.g., dev, prod)."
  type        = string
}

variable "owner" {
  description = "Identifies the team or person responsible for the resource (used for tagging)."
  type        = string
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository to pull images from."
  type        = string
}

variable "domain" {
  description = "Used to set base level domain."
  type        = string
  default     = ""
}

variable "certificate_domain" {
  description = "The full domain name used to request the SSL/TLS certificate (e.g. 'example.com' or 'dev.example.com')."
  type        = string
  default     = ""
}

variable "container_port" {
  description = "Port number that the container listens on."
  type        = number
  default     = 8080
}

variable "alarm_actions_arn_list" {
  description = "List of ARNs for actions to trigger when CloudWatch alarms enter ALARM state."
  type        = list(string)
}

variable "logs_bucket" {
  description = "Name of the S3 bucket to send logs to."
  type        = string
}

variable "desired_count" {
  description = "Number of ECS tasks to run by default."
  type        = number
  default     = 3
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of ECS tasks to maintain when autoscaling is enabled."
  type        = number
  default     = 3
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of ECS tasks allowed when autoscaling is enabled."
  type        = number
  default     = 6
}

variable "is_lb_needed" {
  description = "Whether a Load Balancer is required for this service."
  type        = bool
  default     = false
}

variable "is_service_needed" {
  description = "Whether to create the ECS service resource."
  type        = bool
  default     = true
}

variable "is_autoscaling_needed" {
  description = "Whether to enable autoscaling for the ECS service."
  type        = bool
  default     = true
}

variable "environment_vars" {
  description = "Environment variables to set for the ECS container definition."
  type        = list(any)
  default     = [null]
}

variable "ecs_task_definition_memory" {
  description = "Amount of memory (in MiB) to allocate to the ECS task definition."
  type        = number
  default     = 2048
}

variable "ecs_task_definition_cpu" {
  description = "Amount of CPU units to allocate to the ECS task definition."
  type        = number
  default     = 1024
}

variable "ecs_container_definition_memory" {
  description = "Amount of memory (in MiB) to allocate to the ECS container."
  type        = number
  default     = 1024
}

variable "ecs_container_definition_cpu" {
  description = "Amount of CPU units to allocate to the ECS container."
  type        = number
  default     = 512
}

variable "task_role" {
  description = "IAM role ARN to associate with the ECS task."
  default     = null
}

locals {
  is_sandbox    = contains(["ndra", "ndrb", "ndrc", "ndrd"], terraform.workspace)
  is_production = contains(["prod", "pre-prod", "production"], terraform.workspace)
}

