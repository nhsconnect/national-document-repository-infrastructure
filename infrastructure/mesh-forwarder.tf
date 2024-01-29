locals {
  is_mesh_forwarder_enable         = contains(["ndra", "ndrb", "ndrc", "ndrd", "ndr-test"], terraform.workspace)
  inbox_message_count_metric_name  = "MeshInboxMessageCount"
  error_logs_metric_name           = "ErrorCountInLogs"
  sns_topic_error_logs_metric_name = "NumberOfNotificationsFailed"
  mesh_forwarder_metric_namespace  = "MeshForwarder"
  sns_topic_namespace              = "AWS/SNS"
  mesh_forwarder_sns_topic_name    = "${var.environment}-mesh-forwarder-nems-events-sns-topic"
  alarm_actions                    = [try(aws_sns_topic.alarm_notifications_topic[0].arn, null)]
  account_id                       = data.aws_caller_identity.current.account_id
  environment_variables = [
    { "name" : "MESH_URL", "value" : var.mesh_url },
    { "name" : "MESH_MAILBOX_SSM_PARAM_NAME", "value" : var.mesh_mailbox_ssm_param_name },
    { "name" : "MESH_PASSWORD_SSM_PARAM_NAME", "value" : var.mesh_password_ssm_param_name },
    { "name" : "MESH_SHARED_KEY_SSM_PARAM_NAME", "value" : var.mesh_shared_key_ssm_param_name },
    { "name" : "MESH_CLIENT_CERT_SSM_PARAM_NAME", "value" : var.mesh_client_cert_ssm_param_name },
    { "name" : "MESH_CLIENT_KEY_SSM_PARAM_NAME", "value" : var.mesh_client_key_ssm_param_name },
    { "name" : "MESH_CA_CERT_SSM_PARAM_NAME", "value" : var.mesh_ca_cert_ssm_param_name },
    { "name" : "SNS_TOPIC_ARN", "value" : try(module.sns-nems-queue-topic[0].arn, "") },
    { "name" : "MESSAGE_DESTINATION", "value" : var.message_destination },
    { "name" : "DISABLE_MESSAGE_HEADER_VALIDATION", "value" : var.disable_message_header_validation },
    { "name" : "POLL_FREQUENCY", "value" : var.poll_frequency }
  ]
  ecs_cluster_id = try(aws_ecs_cluster.mesh-forwarder-ecs-cluster[0].id, null)
}

# ECS
resource "aws_ecs_service" "mesh_forwarder" {
  count           = local.is_mesh_forwarder_enable ? 1 : 0
  name            = "${var.environment}-${var.mesh_component_name}-service"
  cluster         = local.ecs_cluster_id
  task_definition = aws_ecs_task_definition.forwarder[0].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ndr_mesh_sg.id]
    subnets         = [for subnet in module.ndr-vpc-ui.private_subnets : subnet]
  }
}

resource "aws_ecs_cluster" "mesh-forwarder-ecs-cluster" {
  name  = "${var.environment}-${var.mesh_component_name}-ecs-cluster"
  count = local.is_mesh_forwarder_enable ? 1 : 0

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.environment}-${var.mesh_component_name}"
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_ecs_task_definition" "forwarder" {
  count = local.is_mesh_forwarder_enable ? 1 : 0

  family = var.mesh_component_name
  container_definitions = jsonencode([
    {
      name        = "mesh-forwarder"
      image       = "${data.aws_ecr_repository.mesh_s3_forwarder.repository_url}"
      environment = local.environment_variables
      essential   = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.mesh_log_group[0].name
          awslogs-region        = var.region
          awslogs-stream-prefix = terraform.workspace
        }
      }
    }
  ])
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags = merge(
    {
      Name = "${var.environment}-mesh-forwarder"
    }
  )
  execution_role_arn = aws_iam_role.ecs_execution[0].arn
  task_role_arn      = aws_iam_role.mesh_forwarder[0].arn
}

# ECR
data "aws_ecr_repository" "mesh_s3_forwarder" {
  name = "ndr-shared-${var.mesh_component_name}"
}

data "aws_iam_policy_document" "ecr_policy_doc" {
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]

    resources = [
      data.aws_ecr_repository.mesh_s3_forwarder.arn
    ]
  }
  statement {
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
}


# ECS IAM roles
resource "aws_iam_role" "mesh_forwarder" {
  count              = local.is_mesh_forwarder_enable ? 1 : 0
  name               = "${var.environment}-${var.mesh_component_name}-EcsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs-assume-role-policy.json
  description        = "Role assumed by ${var.mesh_component_name} ECS task"
  inline_policy {
    name   = "${var.environment}-${var.mesh_component_name}-kms"
    policy = data.aws_iam_policy_document.kms_policy_doc.json
  }
  inline_policy {
    name   = "${var.environment}-${var.mesh_component_name}-ecr"
    policy = data.aws_iam_policy_document.ecr_policy_doc.json
  }
  inline_policy {
    name   = "${var.environment}-${var.mesh_component_name}-logs"
    policy = data.aws_iam_policy_document.logs_policy_doc.json
  }
  inline_policy {
    name   = "${var.environment}-${var.mesh_component_name}-ssm"
    policy = data.aws_iam_policy_document.ssm_policy_doc.json
  }
  inline_policy {
    name   = "${var.environment}-${var.mesh_component_name}-sns"
    policy = data.aws_iam_policy_document.sns_policy_doc[0].json
  }
}


data "aws_iam_policy_document" "ecs-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "logs_policy_doc" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${var.region}:${local.account_id}:log-group:/nhs/deductions/${var.environment}-${local.account_id}/${var.mesh_component_name}:*"
    ]
  }
}

data "aws_iam_policy_document" "ssm_policy_doc" {
  statement {
    actions = [
      "ssm:Get*"
    ]
    resources = [
      "arn:aws:ssm:${var.region}:${local.account_id}:parameter/repo/${var.environment}/user-input/external/mesh-mailbox*",
    ]
  }
}

data "aws_iam_policy_document" "sns_policy_doc" {
  count = local.is_mesh_forwarder_enable ? 1 : 0
  statement {
    actions = [
      "sns:Publish"
    ]
    resources = [
      try(module.sns-nems-queue-topic[0].arn, null)
    ]
  }
}

data "aws_iam_policy_document" "kms_policy_doc" {
  statement {
    actions = [
      "kms:*"
    ]
    resources = [
      module.sns_encryption_key.kms_arn
    ]
  }
}

resource "aws_iam_role" "ecs_execution" {
  count              = local.is_mesh_forwarder_enable ? 1 : 0
  name               = "${var.environment}-deductions-mesh-forwarder-task"
  description        = "ECS task role for launching mesh s3 forwarder"
  assume_role_policy = data.aws_iam_policy_document.ecs-assume-role-policy.json
  inline_policy {
    name   = "${var.environment}-${var.mesh_component_name}-ecs-execution"
    policy = data.aws_iam_policy_document.ecs_execution[0].json
  }
}

data "aws_iam_policy_document" "ecs_execution" {
  count = local.is_mesh_forwarder_enable ? 1 : 0
  statement {
    sid = "GetEcrAuthToken"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid = "DownloadEcrImage"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = [
      data.aws_ecr_repository.mesh_s3_forwarder.arn
    ]
  }

  statement {
    sid = "CloudwatchLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.mesh_log_group[0].arn}:*"
    ]
  }
}

# SQS
module "sqs-nems-queue" {
  source            = "./modules/sqs"
  name              = "${var.mesh_component_name}_name-nems-queue"
  count             = local.is_mesh_forwarder_enable ? 1 : 0
  environment       = var.environment
  owner             = var.owner
  message_retention = 1800
  kms_master_key_id = module.sns_encryption_key.id
  enable_sse        = null
}

data "aws_iam_policy_document" "sqs_policy_doc" {
  count = local.is_mesh_forwarder_enable ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]

    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }

    resources = [
      module.sqs-nems-queue[0].sqs_arn
    ]

    condition {
      test     = "ArnEquals"
      values   = [module.sns-nems-queue-topic[0].arn]
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_sqs_queue_policy" "nems_events_subscription" {
  count     = local.is_mesh_forwarder_enable ? 1 : 0
  queue_url = module.sqs-nems-queue[0].sqs_id
  policy    = data.aws_iam_policy_document.sqs_policy_doc[0].json
}

# SNS
module "sns-nems-queue-topic" {
  count                 = local.is_mesh_forwarder_enable ? 1 : 0
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  current_account_id    = data.aws_caller_identity.current.account_id
  topic_name            = "${var.mesh_component_name}-nems-events-sns-topic"
  topic_protocol        = "sqs"
  sqs_feedback          = { failure_role_arn = aws_iam_role.sns_failure_feedback_role[0].arn }
  depends_on            = [module.sqs-nems-queue, module.sns_encryption_key]
  topic_endpoint        = module.sqs-nems-queue[0].endpoint
  raw_message_delivery  = true
  delivery_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudwatch.amazonaws.com"
        },
        "Action" : [
          "SNS:Publish",
        ],
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:cloudwatch:eu-west-2:${data.aws_caller_identity.current.account_id}:alarm:*"
          }
        }
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "sns_failure_feedback_role" {
  count              = local.is_mesh_forwarder_enable ? 1 : 0
  name               = "${var.environment}-${var.mesh_component_name}-sns-failure-feedback-role"
  assume_role_policy = data.aws_iam_policy_document.sns_service_assume_role_policy.json
  description        = "Allows logging of SNS delivery failures in ${var.mesh_component_name}"
  inline_policy {
    name   = "${var.environment}-${var.mesh_component_name}-sns-failure-feedback"
    policy = data.aws_iam_policy_document.sns_failure_feedback_policy.json
  }
}

data "aws_iam_policy_document" "sns_service_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "sns.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "sns_failure_feedback_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy"
    ]
    resources = [
      "*"
    ]
  }
}

# CloudWatch groups
resource "aws_cloudwatch_log_group" "mesh_log_group" {
  count = local.is_mesh_forwarder_enable ? 1 : 0
  name  = "/nhs/deductions/${var.environment}/${var.mesh_component_name}"

  tags = {
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_cloudwatch_log_metric_filter" "inbox_message_count" {
  count          = local.is_mesh_forwarder_enable ? 1 : 0
  name           = "${var.environment}-mesh-inbox-message-count"
  pattern        = "{ $.event = \"COUNT_MESSAGES\" }"
  log_group_name = aws_cloudwatch_log_group.mesh_log_group[0].name

  metric_transformation {
    name      = local.inbox_message_count_metric_name
    namespace = local.mesh_forwarder_metric_namespace
    value     = "$.inboxMessageCount"
  }
}

resource "aws_cloudwatch_metric_alarm" "inbox-messages-not-consumed" {
  count               = local.is_mesh_forwarder_enable ? 1 : 0
  alarm_name          = "${var.environment}-mesh-inbox-messages-not-consumed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_alarm_evaluation_periods
  metric_name         = local.inbox_message_count_metric_name
  namespace           = local.mesh_forwarder_metric_namespace
  period              = "60"
  statistic           = "Minimum"
  threshold           = "0"
  alarm_description   = "This alarm is triggered if the mailbox doesn't get empty in a given evaluation time period"
  treat_missing_data  = "breaching"
  actions_enabled     = "true"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

resource "aws_cloudwatch_log_metric_filter" "error_log_metric_filter" {
  count          = local.is_mesh_forwarder_enable ? 1 : 0
  name           = "${var.environment}-${var.mesh_component_name}-error-logs"
  pattern        = "{ $.error = * }"
  log_group_name = aws_cloudwatch_log_group.mesh_log_group[0].name

  metric_transformation {
    name          = local.error_logs_metric_name
    namespace     = local.mesh_forwarder_metric_namespace
    value         = 1
    default_value = 0
  }
}

resource "aws_cloudwatch_metric_alarm" "error_log_alarm" {
  count               = local.is_mesh_forwarder_enable ? 1 : 0
  alarm_name          = "${var.environment}-${var.mesh_component_name}-error-logs"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  evaluation_periods  = "1"
  period              = "60"
  metric_name         = local.error_logs_metric_name
  namespace           = local.mesh_forwarder_metric_namespace
  statistic           = "Sum"
  alarm_description   = "This alarm monitors errors logs in ${var.mesh_component_name}"
  treat_missing_data  = "notBreaching"
  actions_enabled     = "true"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "sns_topic_error_log_alarm" {
  count               = local.is_mesh_forwarder_enable ? 1 : 0
  alarm_name          = "${local.mesh_forwarder_sns_topic_name}-error-logs"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  evaluation_periods  = "1"
  period              = "60"
  metric_name         = local.sns_topic_error_logs_metric_name
  namespace           = local.sns_topic_namespace
  dimensions = {
    TopicName = local.mesh_forwarder_sns_topic_name
  }
  statistic          = "Sum"
  alarm_description  = "This alarm monitors errors logs in ${local.mesh_forwarder_sns_topic_name}"
  treat_missing_data = "notBreaching"
  actions_enabled    = "true"
  alarm_actions      = local.alarm_actions
  ok_actions         = local.alarm_actions
}

# Output SSM Mesh forwarder
resource "aws_ssm_parameter" "sns_sqs_kms_key_id" {
  count = local.is_mesh_forwarder_enable ? 1 : 0
  name  = "/repo/${var.environment}/output/${var.mesh_component_name}/sns-sqs-kms-key-id"
  type  = "String"
  value = module.sns_encryption_key.id

  tags = {
    CreatedBy   = var.mesh_component_name
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_ssm_parameter" "nems_events_topic_arn" {
  count = local.is_mesh_forwarder_enable ? 1 : 0
  name  = "/repo/${var.environment}/output/${var.mesh_component_name}/nems-events-topic-arn"
  type  = "String"
  value = module.sns-nems-queue-topic[0].arn

  tags = {
    CreatedBy   = var.mesh_component_name
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_ssm_parameter" "nems_events_observability" {
  count = local.is_mesh_forwarder_enable ? 1 : 0
  name  = "/repo/${var.environment}/output/${var.mesh_component_name}/nems-events-observability"
  type  = "String"
  value = module.sqs-nems-queue[0].sqs_arn
  tags = {
    CreatedBy   = var.mesh_component_name
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_security_group" "ndr_mesh_sg" {
  name        = "mesh-forwarder-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.ndr-vpc-ui.vpc_id
  tags = {
    Name        = "${terraform.workspace}-mesh-forwarder-sg"
    Environment = terraform.workspace
  }
}

resource "aws_vpc_security_group_egress_rule" "ndr_ecs_sg_egress_http" {
  security_group_id = aws_security_group.ndr_mesh_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ndr_ecs_sg_ingress_http" {
  security_group_id = aws_security_group.ndr_mesh_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "ndr_ecs_sg_egress_https" {
  security_group_id = aws_security_group.ndr_mesh_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "ndr_ecs_sg_ingress_https" {
  security_group_id = aws_security_group.ndr_mesh_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
