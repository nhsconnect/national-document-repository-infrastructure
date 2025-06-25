# AWS AppConfig Module

## Features

- AppConfig Application and Environment resources
- Configuration Profile with Hosted Configuration Version
- Deployment Strategy for controlled rollouts
- Triggered Deployment resource to apply configuration
- IAM policy granting read-only access to AppConfig
- Tagging via environment and owner

---

## Usage

```hcl
module "app_config" {
  source = "./modules/app-config"

  # Required: Name of the AppConfig environment (e.g. "dev", "prod")
  config_environment_name = "prod"

  # Required: Name of the configuration profile to define (e.g. "my-feature-flags")
  config_profile_name = "app-profile"

  # Required: Used for tagging and logical naming
  environment = "prod"

  # Required: Owner or team responsible
  owner = "platform"
}

```

<!-- BEGIN_TF_DOCS -->

## RequirementsS

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                            | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_appconfig_application.ndr-app-config-application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_application)                                       | resource    |
| [aws_appconfig_configuration_profile.ndr-app-config-profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_configuration_profile)                       | resource    |
| [aws_appconfig_deployment.ndr-app-config-deployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_deployment)                                          | resource    |
| [aws_appconfig_deployment_strategy.ndr-app-config-deployment-strategy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_deployment_strategy)               | resource    |
| [aws_appconfig_environment.ndr-app-config-environment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_environment)                                       | resource    |
| [aws_appconfig_hosted_configuration_version.ndr-app-config-profile-version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_hosted_configuration_version) | resource    |
| [aws_iam_policy.app_config_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                                      | resource    |
| [aws_iam_policy_document.app_config_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                 | data source |

## Inputs

| Name                                                                                                   | Description | Type     | Default | Required |
| ------------------------------------------------------------------------------------------------------ | ----------- | -------- | ------- | :------: |
| <a name="input_config_environment_name"></a> [config_environment_name](#input_config_environment_name) | n/a         | `string` | n/a     |   yes    |
| <a name="input_config_profile_name"></a> [config_profile_name](#input_config_profile_name)             | n/a         | `string` | n/a     |   yes    |
| <a name="input_environment"></a> [environment](#input_environment)                                     | n/a         | `string` | n/a     |   yes    |
| <a name="input_owner"></a> [owner](#input_owner)                                                       | n/a         | `string` | n/a     |   yes    |

## Outputs

| Name                                                                                                                                         | Description |
| -------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_app_config_application_id"></a> [app_config_application_id](#output_app_config_application_id)                               | n/a         |
| <a name="output_app_config_configuration_profile_id"></a> [app_config_configuration_profile_id](#output_app_config_configuration_profile_id) | n/a         |
| <a name="output_app_config_environment_id"></a> [app_config_environment_id](#output_app_config_environment_id)                               | n/a         |
| <a name="output_app_config_policy"></a> [app_config_policy](#output_app_config_policy)                                                       | n/a         |
| <a name="output_app_config_policy_arn"></a> [app_config_policy_arn](#output_app_config_policy_arn)                                           | n/a         |

<!-- END_TF_DOCS -->
