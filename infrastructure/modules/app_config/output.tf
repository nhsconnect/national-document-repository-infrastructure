output "app_config_application_id" {
  value = aws_appconfig_application.ndr-app-config-application.id
}

output "app_config_environment_id" {
  value = aws_appconfig_environment.ndr-app-config-environment.environment_id
}

output "app_config_configuration_profile_id" {
  value = aws_appconfig_configuration_profile.ndr-app-config-profile.configuration_profile_id
}

output "app_config_policy" {
  value = data.aws_iam_policy_document.app_config_policy.json
}

output "app_config_policy_arn" {
  value = aws_iam_policy.app_config_policy.arn
}