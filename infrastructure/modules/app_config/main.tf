locals {
  is_sandbox_dev_or_test = contains(["ndra", "ndrb", "ndrc", "ndrd", "ndr-dev", "ndr-test"], terraform.workspace)
  current_config_path = (
    local.is_sandbox_dev_or_test
    ? "${path.module}/configurations/2024-02-21-dev.json"
    : "${path.module}/configurations/2024-05-21-${terraform.workspace}.json"
  )
}

resource "aws_appconfig_application" "ndr-app-config-application" {
  name        = "RepositoryConfiguration-${terraform.workspace}"
  description = "AppConfig Application for ${terraform.workspace}"
}

resource "aws_appconfig_environment" "ndr-app-config-environment" {
  application_id = aws_appconfig_application.ndr-app-config-application.id
  name           = var.config_environment_name
  description    = "AppConfig Environment for ${terraform.workspace}"

  tags = {
    Name        = "${terraform.workspace}_repo_app_config_environment"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }

  depends_on = [aws_appconfig_application.ndr-app-config-application]
}

resource "aws_appconfig_configuration_profile" "ndr-app-config-profile" {
  application_id = aws_appconfig_application.ndr-app-config-application.id
  name           = var.config_profile_name
  description    = "AppConfig Configuration Profile for ${terraform.workspace}"
  location_uri   = "hosted"
  type           = "AWS.AppConfig.FeatureFlags"

  tags = {
    Name        = "${terraform.workspace}_repo_app_config_profile"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }

  depends_on = [aws_appconfig_application.ndr-app-config-application]
}

resource "aws_appconfig_hosted_configuration_version" "ndr-app-config-profile-version" {
  application_id           = aws_appconfig_application.ndr-app-config-application.id
  configuration_profile_id = aws_appconfig_configuration_profile.ndr-app-config-profile.configuration_profile_id
  content                  = file(local.current_config_path)
  content_type             = "application/json"

  depends_on = [
    aws_appconfig_configuration_profile.ndr-app-config-profile
  ]
}

resource "aws_appconfig_deployment_strategy" "ndr-app-config-deployment-strategy" {
  name                           = "${terraform.workspace}_RepoAppConfigDeploymentStrategy"
  deployment_duration_in_minutes = 0
  final_bake_time_in_minutes     = 0
  growth_factor                  = "100.0"
  growth_type                    = "LINEAR"
  replicate_to                   = "NONE"
}

resource "aws_appconfig_deployment" "ndr-app-config-deployment" {
  application_id           = aws_appconfig_application.ndr-app-config-application.id
  environment_id           = aws_appconfig_environment.ndr-app-config-environment.environment_id
  configuration_profile_id = aws_appconfig_configuration_profile.ndr-app-config-profile.configuration_profile_id
  configuration_version    = aws_appconfig_hosted_configuration_version.ndr-app-config-profile-version.version_number
  deployment_strategy_id   = aws_appconfig_deployment_strategy.ndr-app-config-deployment-strategy.id

  depends_on = [
    aws_appconfig_environment.ndr-app-config-environment,
    aws_appconfig_deployment_strategy.ndr-app-config-deployment-strategy,
    aws_appconfig_hosted_configuration_version.ndr-app-config-profile-version
  ]
}

resource "aws_iam_policy" "app_config_policy" {
  name = "${terraform.workspace}_app_config_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "appconfig:GetLatestConfiguration",
          "appconfig:StartConfigurationSession"
        ],
        Resource = [
          "arn:aws:appconfig:*:*:application/${aws_appconfig_application.ndr-app-config-application.id}/environment/${aws_appconfig_environment.ndr-app-config-environment.environment_id}/configuration/${aws_appconfig_configuration_profile.ndr-app-config-profile.configuration_profile_id}"
        ]
      }
    ]
  })
}

data "aws_iam_policy_document" "app_config_policy" {
  statement {
    actions = [
      "appconfig:GetLatestConfiguration",
      "appconfig:StartConfigurationSession"
    ]
    resources = [
      "arn:aws:appconfig:*:*:application/${aws_appconfig_application.ndr-app-config-application.id}/environment/${aws_appconfig_environment.ndr-app-config-environment.environment_id}/configuration/${aws_appconfig_configuration_profile.ndr-app-config-profile.configuration_profile_id}"
    ]
  }
}