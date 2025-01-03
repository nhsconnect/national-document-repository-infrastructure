## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.ndr_ecs_service_autoscale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.ndr_ecs_service_autoscale_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ndr_ecs_service_autoscale_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.awslogs-ndr-ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ecs_cluster_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.alb_alarm_4XX](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.alb_alarm_5XX](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ndr_ecs_service_cpu_high_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ndr_ecs_service_cpu_low_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ecs_cluster.ndr_ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.ndr_ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.ndr_ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb.ecs_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.ecs_lb_tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.ndr_ecs_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.ndr_ecs_sg_egress_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.ndr_ecs_sg_egress_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ndr_ecs_sg_ingress_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ndr_ecs_sg_ingress_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_acm_certificate.amazon_issued](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions_arn_list"></a> [alarm\_actions\_arn\_list](#input\_alarm\_actions\_arn\_list) | n/a | `list(string)` | n/a | yes |
| <a name="input_autoscaling_max_capacity"></a> [autoscaling\_max\_capacity](#input\_autoscaling\_max\_capacity) | n/a | `number` | `6` | no |
| <a name="input_autoscaling_min_capacity"></a> [autoscaling\_min\_capacity](#input\_autoscaling\_min\_capacity) | n/a | `number` | `3` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"eu-west-2"` | no |
| <a name="input_certificate_domain"></a> [certificate\_domain](#input\_certificate\_domain) | n/a | `string` | `""` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | n/a | `number` | `8080` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | n/a | `number` | `3` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | n/a | `string` | `""` | no |
| <a name="input_ecr_repository_url"></a> [ecr\_repository\_url](#input\_ecr\_repository\_url) | n/a | `any` | n/a | yes |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_ecs_cluster_service_name"></a> [ecs\_cluster\_service\_name](#input\_ecs\_cluster\_service\_name) | n/a | `string` | n/a | yes |
| <a name="input_ecs_container_definition_cpu"></a> [ecs\_container\_definition\_cpu](#input\_ecs\_container\_definition\_cpu) | n/a | `number` | `512` | no |
| <a name="input_ecs_container_definition_memory"></a> [ecs\_container\_definition\_memory](#input\_ecs\_container\_definition\_memory) | n/a | `number` | `1024` | no |
| <a name="input_ecs_launch_type"></a> [ecs\_launch\_type](#input\_ecs\_launch\_type) | n/a | `string` | `"FARGATE"` | no |
| <a name="input_ecs_task_definition_cpu"></a> [ecs\_task\_definition\_cpu](#input\_ecs\_task\_definition\_cpu) | n/a | `number` | `1024` | no |
| <a name="input_ecs_task_definition_memory"></a> [ecs\_task\_definition\_memory](#input\_ecs\_task\_definition\_memory) | n/a | `number` | `2048` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_environment_vars"></a> [environment\_vars](#input\_environment\_vars) | n/a | `list` | <pre>[<br/>  null<br/>]</pre> | no |
| <a name="input_is_autoscaling_needed"></a> [is\_autoscaling\_needed](#input\_is\_autoscaling\_needed) | n/a | `bool` | `true` | no |
| <a name="input_is_lb_needed"></a> [is\_lb\_needed](#input\_is\_lb\_needed) | n/a | `bool` | `false` | no |
| <a name="input_is_service_needed"></a> [is\_service\_needed](#input\_is\_service\_needed) | n/a | `bool` | `true` | no |
| <a name="input_logs_bucket"></a> [logs\_bucket](#input\_logs\_bucket) | n/a | `any` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | n/a | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | `any` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | n/a | `any` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | n/a | `string` | n/a | yes |
| <a name="input_task_role"></a> [task\_role](#input\_task\_role) | n/a | `any` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_arn"></a> [certificate\_arn](#output\_certificate\_arn) | The arn of certificate that load balancer is using |
| <a name="output_container_port"></a> [container\_port](#output\_container\_port) | The container port number of docker image, which was provided as input variable of this module |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | n/a |
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | n/a |
| <a name="output_load_balancer_arn"></a> [load\_balancer\_arn](#output\_load\_balancer\_arn) | The arn of the load balancer |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | n/a |
