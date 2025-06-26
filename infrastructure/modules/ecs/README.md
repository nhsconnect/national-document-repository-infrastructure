# ECS Fargate Service Module

## Features

This module supports the following optional components:

- ECS Cluster and Service (with Fargate launch type)
- Load Balancer (ALB) with HTTP/HTTPS listeners
- ACM Certificate lookup for HTTPS via domain name
- Log Group creation for ECS service logs
- IAM roles and policy attachments for execution
- CloudWatch Alarms for CPU and ALB status codes
- Custom security groups and subnet configuration

---

## Usage

```hcl
module "ecs_service" {
  source = "./modules/ecs"

  # Required configuration
  alarm_actions_arn_list     = ["arn:aws:sns:region:acct:alarm-topic"]  # CloudWatch alarm actions
  ecr_repository_url         = "123456789012.dkr.ecr.eu-west-2.amazonaws.com/my-app"
  ecs_cluster_name           = "my-ecs-cluster"
  ecs_cluster_service_name   = "my-app-service"
  environment                = "prod"
  owner                      = "platform"
  logs_bucket                = "my-cloudwatch-logs"
  private_subnets            = ["subnet-abc123", "subnet-def456"]
  public_subnets             = ["subnet-xyz789", "subnet-uvw321"]
  sg_name                    = "my-service-sg"
  vpc_id                     = "vpc-0abc123"

  # ECS task/service configuration
  container_port             = 8080           # Port exposed by the Docker container
  desired_count              = 3              # Number of tasks to run
  ecs_launch_type            = "FARGATE"
  ecs_container_definition_cpu    = 512
  ecs_container_definition_memory = 1024
  ecs_task_definition_cpu         = 1024
  ecs_task_definition_memory      = 2048
  task_role                       = "arn:aws:iam::123456789012:role/my-task-role"

  # Optional ALB and HTTPS setup
  is_lb_needed         = true
  certificate_domain   = "myapp.example.com"
  domain               = "example.com"
}

```

<!-- BEGIN_TF_DOCS -->                                                                                        |

<!-- END_TF_DOCS -->
