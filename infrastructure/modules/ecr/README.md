# ECR Repository Module-

## Features

- ECR repository with custom name derived from app and environment
- Lifecycle policy to clean up unused images automatically
- Cross-account access via repository policy
- Resource tagging with environment and owner
- Output of repository URL for use in pipelines or other modules

---

## Usage

```hcl
module "ecr_repository" {
  source = "./modules/ecr"

  # Required
  app_name = "my-app"

  # Required
  environment = "prod"

  # Required
  current_account_id = "123456789012"

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
| [aws_ecr_lifecycle_policy.ndr_ecr_lifecycle_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.ndr-ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.ndr_ecr_repository_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name of the application (used in repository naming). | `string` | n/a | yes |
| <a name="input_current_account_id"></a> [current\_account\_id](#input\_current\_account\_id) | AWS account ID where the repository is created. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment tag used for naming and labeling (e.g., dev, prod). | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Identifies the team or person responsible for the resource (used for tagging). | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | n/a |
<!-- END_TF_DOCS -->
