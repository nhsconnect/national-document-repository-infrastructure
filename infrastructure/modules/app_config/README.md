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

  # Required
  config_environment_name = "prod"

  # Required
  config_profile_name = "app-profile"

  # Required
  environment = "prod"

  # Required
  owner = "platform"
}

```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
## Resources

| Name | Type |
|------|------|
| [aws_appconfig_application.ndr-app-config-application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_application) | resource |
| [aws_appconfig_configuration_profile.ndr-app-config-profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_configuration_profile) | resource |
| [aws_appconfig_deployment.ndr-app-config-deployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_deployment) | resource |
| [aws_appconfig_deployment_strategy.ndr-app-config-deployment-strategy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_deployment_strategy) | resource |
| [aws_appconfig_environment.ndr-app-config-environment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_environment) | resource |
| [aws_appconfig_hosted_configuration_version.ndr-app-config-profile-version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_hosted_configuration_version) | resource |
| [aws_iam_policy.app_config_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [terraform_data.current_config_file_content](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [aws_iam_policy_document.app_config_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_environment_name"></a> [config\_environment\_name](#input\_config\_environment\_name) | n/a | `string` | n/a | yes |
| <a name="input_config_profile_name"></a> [config\_profile\_name](#input\_config\_profile\_name) | n/a | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | n/a | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_config_application_id"></a> [app\_config\_application\_id](#output\_app\_config\_application\_id) | n/a |
| <a name="output_app_config_configuration_profile_id"></a> [app\_config\_configuration\_profile\_id](#output\_app\_config\_configuration\_profile\_id) | n/a |
| <a name="output_app_config_environment_id"></a> [app\_config\_environment\_id](#output\_app\_config\_environment\_id) | n/a |
| <a name="output_app_config_policy"></a> [app\_config\_policy](#output\_app\_config\_policy) | n/a |
| <a name="output_app_config_policy_arn"></a> [app\_config\_policy\_arn](#output\_app\_config\_policy\_arn) | n/a |
<!-- END_TF_DOCS -->
