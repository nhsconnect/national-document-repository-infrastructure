module "ndr-ecs-fargate-app" {
  source                   = "./modules/ecs"
  ecs_cluster_name         = "app-cluster"
  is_lb_needed             = true
  is_autoscaling_needed    = true
  is_service_needed        = true
  vpc_id                   = module.ndr-vpc-ui.vpc_id
  public_subnets           = module.ndr-vpc-ui.public_subnets
  private_subnets          = module.ndr-vpc-ui.private_subnets
  sg_name                  = "${terraform.workspace}-fargate-sg"
  ecs_launch_type          = "FARGATE"
  ecs_cluster_service_name = "${terraform.workspace}-ecs-cluster-service"
  ecr_repository_url       = module.ndr-docker-ecr-ui.ecr_repository_url
  environment              = var.environment
  owner                    = var.owner
  domain                   = var.domain
  certificate_domain       = var.certificate_domain
  container_port           = 80
  alarm_actions_arn_list   = local.is_sandbox ? [] : [aws_sns_topic.alarm_notifications_topic[0].arn]
  logs_bucket              = aws_s3_bucket.logs_bucket.bucket
}


module "ndr-ecs-container-port-ssm-parameter" {
  source              = "./modules/ssm_parameter"
  name                = "container_port"
  description         = "Docker container port number for ${var.environment}"
  resource_depends_on = module.ndr-ecs-fargate-app
  value               = module.ndr-ecs-fargate-app.container_port
  type                = "SecureString"
  owner               = var.owner
  environment         = var.environment
}

module "ndr-ecs-fargate-ods-update" {
  count                    = local.is_sandbox ? 0 : 1
  source                   = "./modules/ecs"
  ecs_cluster_name         = "ods-weekly-update"
  vpc_id                   = module.ndr-vpc-ui.vpc_id
  public_subnets           = module.ndr-vpc-ui.public_subnets
  private_subnets          = module.ndr-vpc-ui.private_subnets
  sg_name                  = "${terraform.workspace}-ods-weekly-update-sg"
  ecs_launch_type          = "FARGATE"
  ecs_cluster_service_name = "${terraform.workspace}-ods-weekly-update"
  ecr_repository_url       = module.ndr-docker-ecr-weekly-ods-update[0].ecr_repository_url
  environment              = var.environment
  owner                    = var.owner
  container_port           = 80
  is_autoscaling_needed    = false
  is_lb_needed             = false
  is_service_needed        = false
  alarm_actions_arn_list   = []
  logs_bucket              = aws_s3_bucket.logs_bucket.bucket
  task_role                = aws_iam_role.ods_weekly_update_task_role[0].arn
  environment_vars = [
    {
      "name" : "table_name",
      "value" : module.lloyd_george_reference_dynamodb_table.table_name
    },
    {
      "name" : "PDS_FHIR_IS_STUBBED",
      "value" : tostring(local.is_sandbox)
    },
    {
      "name" : "LLOYD_GEORGE_BUCKET_NAME",
      "value" : "${terraform.workspace}-${var.lloyd_george_bucket_name}"
    },
    {
      "name" : "LLOYD_GEORGE_DYNAMODB_NAME",
      "value" : "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    },
    {
      "name" : "DOCUMENT_STORE_BUCKET_NAME",
      "value" : "${terraform.workspace}-${var.docstore_bucket_name}"
    },
    {
      "name" : "DOCUMENT_STORE_DYNAMODB_NAME",
      "value" : "${terraform.workspace}_${var.docstore_dynamodb_table_name}"
    },
    {
      "name" : "STATISTICAL_REPORTS_BUCKET",
      "value" : "${terraform.workspace}-${var.statistical_reports_bucket_name}"
    },
    {
      "name" : "STATISTICS_TABLE",
      "value" : "${terraform.workspace}_${var.statistics_dynamodb_table_name}"
    },
    {
      "name" : "WORKSPACE",
      "value" : terraform.workspace
    }
  ]
  ecs_container_definition_memory = 5120
  ecs_container_definition_cpu    = 1024
  ecs_task_definition_memory      = 5120
  ecs_task_definition_cpu         = 1024
}

resource "aws_iam_role" "ods_weekly_update_task_role" {
  count = local.is_sandbox ? 0 : 1
  name  = "${terraform.workspace}_ods_weekly_update_task_role"
  managed_policy_arns = [
    module.lloyd_george_reference_dynamodb_table.dynamodb_policy,
    aws_iam_policy.ssm_access_policy.arn,
    module.statistics_dynamodb_table.dynamodb_policy,
    module.statistical-reports-store.s3_object_access_policy,
    module.ndr-app-config.app_config_policy_arn,
    module.ndr-lloyd-george-store.s3_list_object_policy,
    module.ndr-document-store.s3_list_object_policy,
    module.document_reference_dynamodb_table.dynamodb_policy,
    aws_iam_policy.cloudwatch_log_query_policy.arn
  ]
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : [
              "ecs-tasks.amazonaws.com"
            ]
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}