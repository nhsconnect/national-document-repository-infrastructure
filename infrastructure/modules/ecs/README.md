<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                        | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_appautoscaling_policy.ndr_ecs_service_autoscale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy)               | resource    |
| [aws_appautoscaling_policy.ndr_ecs_service_autoscale_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy)                 | resource    |
| [aws_appautoscaling_target.ndr_ecs_service_autoscale_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target)             | resource    |
| [aws_cloudwatch_log_group.awslogs-ndr-ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                                | resource    |
| [aws_cloudwatch_log_group.ecs_cluster_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                               | resource    |
| [aws_cloudwatch_metric_alarm.alb_alarm_4XX](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm)                            | resource    |
| [aws_cloudwatch_metric_alarm.alb_alarm_5XX](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm)                            | resource    |
| [aws_cloudwatch_metric_alarm.ndr_ecs_service_cpu_high_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm)           | resource    |
| [aws_cloudwatch_metric_alarm.ndr_ecs_service_cpu_low_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm)            | resource    |
| [aws_ecs_cluster.ndr_ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster)                                                  | resource    |
| [aws_ecs_service.ndr_ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service)                                                  | resource    |
| [aws_ecs_task_definition.ndr_ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition)                                     | resource    |
| [aws_iam_role.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                              | resource    |
| [aws_iam_role_policy.s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                                                | resource    |
| [aws_iam_role_policy_attachment.ecs_task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                      | resource    |
| [aws_lb.ecs_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)                                                                             | resource    |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener)                                                             | resource    |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener)                                                            | resource    |
| [aws_lb_target_group.ecs_lb_tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group)                                                | resource    |
| [aws_security_group.ndr_ecs_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                                 | resource    |
| [aws_vpc_security_group_egress_rule.ndr_ecs_sg_egress_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule)     | resource    |
| [aws_vpc_security_group_egress_rule.ndr_ecs_sg_egress_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule)    | resource    |
| [aws_vpc_security_group_ingress_rule.ndr_ecs_sg_ingress_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule)  | resource    |
| [aws_vpc_security_group_ingress_rule.ndr_ecs_sg_ingress_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource    |
| [aws_acm_certificate.amazon_issued](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate)                                         | data source |

## Inputs

| Name                                                                                                                           | Description | Type           | Default                      | Required |
| ------------------------------------------------------------------------------------------------------------------------------ | ----------- | -------------- | ---------------------------- | :------: |
| <a name="input_alarm_actions_arn_list"></a> [alarm_actions_arn_list](#input_alarm_actions_arn_list)                            | n/a         | `list(string)` | n/a                          |   yes    |
| <a name="input_autoscaling_max_capacity"></a> [autoscaling_max_capacity](#input_autoscaling_max_capacity)                      | n/a         | `number`       | `6`                          |    no    |
| <a name="input_autoscaling_min_capacity"></a> [autoscaling_min_capacity](#input_autoscaling_min_capacity)                      | n/a         | `number`       | `3`                          |    no    |
| <a name="input_aws_region"></a> [aws_region](#input_aws_region)                                                                | n/a         | `string`       | `"eu-west-2"`                |    no    |
| <a name="input_certificate_domain"></a> [certificate_domain](#input_certificate_domain)                                        | n/a         | `string`       | `""`                         |    no    |
| <a name="input_container_port"></a> [container_port](#input_container_port)                                                    | n/a         | `number`       | `8080`                       |    no    |
| <a name="input_desired_count"></a> [desired_count](#input_desired_count)                                                       | n/a         | `number`       | `3`                          |    no    |
| <a name="input_domain"></a> [domain](#input_domain)                                                                            | n/a         | `string`       | `""`                         |    no    |
| <a name="input_ecr_repository_url"></a> [ecr_repository_url](#input_ecr_repository_url)                                        | n/a         | `any`          | n/a                          |   yes    |
| <a name="input_ecs_cluster_name"></a> [ecs_cluster_name](#input_ecs_cluster_name)                                              | n/a         | `string`       | n/a                          |   yes    |
| <a name="input_ecs_cluster_service_name"></a> [ecs_cluster_service_name](#input_ecs_cluster_service_name)                      | n/a         | `string`       | n/a                          |   yes    |
| <a name="input_ecs_container_definition_cpu"></a> [ecs_container_definition_cpu](#input_ecs_container_definition_cpu)          | n/a         | `number`       | `512`                        |    no    |
| <a name="input_ecs_container_definition_memory"></a> [ecs_container_definition_memory](#input_ecs_container_definition_memory) | n/a         | `number`       | `1024`                       |    no    |
| <a name="input_ecs_launch_type"></a> [ecs_launch_type](#input_ecs_launch_type)                                                 | n/a         | `string`       | `"FARGATE"`                  |    no    |
| <a name="input_ecs_task_definition_cpu"></a> [ecs_task_definition_cpu](#input_ecs_task_definition_cpu)                         | n/a         | `number`       | `1024`                       |    no    |
| <a name="input_ecs_task_definition_memory"></a> [ecs_task_definition_memory](#input_ecs_task_definition_memory)                | n/a         | `number`       | `2048`                       |    no    |
| <a name="input_environment"></a> [environment](#input_environment)                                                             | n/a         | `string`       | n/a                          |   yes    |
| <a name="input_environment_vars"></a> [environment_vars](#input_environment_vars)                                              | n/a         | `list`         | <pre>[<br/> null<br/>]</pre> |    no    |
| <a name="input_is_autoscaling_needed"></a> [is_autoscaling_needed](#input_is_autoscaling_needed)                               | n/a         | `bool`         | `true`                       |    no    |
| <a name="input_is_lb_needed"></a> [is_lb_needed](#input_is_lb_needed)                                                          | n/a         | `bool`         | `false`                      |    no    |
| <a name="input_is_service_needed"></a> [is_service_needed](#input_is_service_needed)                                           | n/a         | `bool`         | `true`                       |    no    |
| <a name="input_logs_bucket"></a> [logs_bucket](#input_logs_bucket)                                                             | n/a         | `any`          | n/a                          |   yes    |
| <a name="input_owner"></a> [owner](#input_owner)                                                                               | n/a         | `string`       | n/a                          |   yes    |
| <a name="input_private_subnets"></a> [private_subnets](#input_private_subnets)                                                 | n/a         | `any`          | n/a                          |   yes    |
| <a name="input_public_subnets"></a> [public_subnets](#input_public_subnets)                                                    | n/a         | `any`          | n/a                          |   yes    |
| <a name="input_sg_name"></a> [sg_name](#input_sg_name)                                                                         | n/a         | `string`       | n/a                          |   yes    |
| <a name="input_task_role"></a> [task_role](#input_task_role)                                                                   | n/a         | `any`          | `null`                       |    no    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                                                            | n/a         | `string`       | n/a                          |   yes    |

## Outputs

| Name                                                                                         | Description                                                                                    |
| -------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| <a name="output_certificate_arn"></a> [certificate_arn](#output_certificate_arn)             | The arn of certificate that load balancer is using                                             |
| <a name="output_container_port"></a> [container_port](#output_container_port)                | The container port number of docker image, which was provided as input variable of this module |
| <a name="output_dns_name"></a> [dns_name](#output_dns_name)                                  | n/a                                                                                            |
| <a name="output_ecs_cluster_arn"></a> [ecs_cluster_arn](#output_ecs_cluster_arn)             | n/a                                                                                            |
| <a name="output_load_balancer_arn"></a> [load_balancer_arn](#output_load_balancer_arn)       | The arn of the load balancer                                                                   |
| <a name="output_security_group_id"></a> [security_group_id](#output_security_group_id)       | n/a                                                                                            |
| <a name="output_task_definition_arn"></a> [task_definition_arn](#output_task_definition_arn) | n/a                                                                                            |

<!-- END_TF_DOCS -->
