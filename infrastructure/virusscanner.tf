locals {
  subnet_1_cidr_block = split(",", data.aws_ssm_parameter.virus_scanning_subnet_cidr_range.value)[0]
  subnet_2_cidr_block = split(",", data.aws_ssm_parameter.virus_scanning_subnet_cidr_range.value)[1]
}

data "aws_ssm_parameter" "cloud_security_admin_email" {
  name = "/prs/${var.cloud_security_email_param_environment}/user-input/cloud-security-admin-email"
}

data "aws_ssm_parameter" "virus_scanning_subnet_cidr_range" {
  name = "/prs/virus-scanner/subnet-cidr-range"
}

resource "aws_subnet" "virus_scanning_subnet1" {
  count = local.is_production ? 1 : 0

  availability_zone = "eu-west-2a"
  vpc_id            = module.ndr-vpc-ui.vpc_id
  cidr_block        = local.subnet_1_cidr_block

  tags = {
    Name        = "Virus scanning subnet for eu-west-2a"
    Environment = var.environment
    Owner       = var.owner
  }
}

resource "aws_subnet" "virus_scanning_subnet2" {
  count = local.is_production ? 1 : 0

  availability_zone = "eu-west-2b"
  vpc_id            = module.ndr-vpc-ui.vpc_id
  cidr_block        = local.subnet_2_cidr_block

  tags = {
    Name        = "Virus scanning subnet for eu-west-2b"
    Environment = var.environment
    Owner       = var.owner
  }
}

resource "aws_route_table" "virus_scanning_route_table" {
  count = local.is_production ? 1 : 0

  vpc_id = module.ndr-vpc-ui.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.ndr-vpc-ui.internet_gateway_id
  }

  tags = {
    Name        = "Virus scanning route table"
    Environment = var.environment
    Owner       = var.owner
  }
}

resource "aws_route_table_association" "virus_scanning_subnet1_route_table_association" {
  count = local.is_production ? 1 : 0

  subnet_id      = aws_subnet.virus_scanning_subnet1[0].id
  route_table_id = aws_route_table.virus_scanning_route_table[0].id
}

resource "aws_route_table_association" "virus_scanning_subnet2_route_table_association" {
  count = local.is_production ? 1 : 0

  subnet_id      = aws_subnet.virus_scanning_subnet2[0].id
  route_table_id = aws_route_table.virus_scanning_route_table[0].id
}

module "cloud_storage_security" {
  count = local.is_production ? 1 : 0

  source                       = "cloudstoragesec/cloud-storage-security/aws"
  version                      = "1.7.1+css8.07.002"
  cidr                         = [var.cloud_security_console_black_hole_address] # This is a reserved address that does not lead anywhere to make sure CloudStorageSecurity console is not available
  email                        = data.aws_ssm_parameter.cloud_security_admin_email.value
  subnet_a_id                  = aws_subnet.virus_scanning_subnet1[0].id
  subnet_b_id                  = aws_subnet.virus_scanning_subnet2[0].id
  vpc                          = module.ndr-vpc-ui.vpc_id
  min_running_agents           = 0
  allow_access_to_all_kms_keys = false
  # num_messages_in_queue_scaling_threshold = 1 # Currently not exposed in the module, will need to be set in the SSM after the terraform has been run.
  # only_scan_when_queue_threshold_exceeded = true # Currently not exposed in the module, will need to be set in the SSM after the terraform has been run.
  custom_resource_tags = {
    Name        = "Virus scanner for Repository"
    Environment = var.environment
    Owner       = var.owner
  }
}

resource "aws_ssm_parameter" "virus_scan_notifications_sns_topic_arn" {
  count = local.is_production ? 1 : 0

  name  = "/prs/${var.environment}/virus-scan-notifications-sns-topic-arn"
  type  = "String"
  value = module.cloud_storage_security[0].proactive_notifications_topic_arn
}

resource "aws_sns_topic_subscription" "proactive_notifications_sns_topic_subscription" {
  for_each  = local.is_production ? toset(nonsensitive(split(",", data.aws_ssm_parameter.cloud_security_notification_email_list.value))) : []
  endpoint  = each.value
  protocol  = "email"
  topic_arn = module.cloud_storage_security[0].proactive_notifications_topic_arn
  filter_policy = jsonencode({
    "notificationType" : ["scanResult"],
    "scanResult" : ["Infected", "Error", "Unscannable", "Suspicious"]
  })
}
