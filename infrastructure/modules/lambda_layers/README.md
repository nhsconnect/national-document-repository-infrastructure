## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.lambda_layer_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_lambda_layer_version.lambda_layer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource |
| [archive_file.lambda_layer_placeholder](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | n/a | `string` | n/a | yes |
| <a name="input_layer_name"></a> [layer\_name](#input\_layer\_name) | n/a | `string` | n/a | yes |
| <a name="input_layer_zip_file_name"></a> [layer\_zip\_file\_name](#input\_layer\_zip\_file\_name) | n/a | `string` | `"placeholder_lambda_payload.zip"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_layer_arn"></a> [lambda\_layer\_arn](#output\_lambda\_layer\_arn) | Outputs |
| <a name="output_lambda_layer_policy_arn"></a> [lambda\_layer\_policy\_arn](#output\_lambda\_layer\_policy\_arn) | n/a |
