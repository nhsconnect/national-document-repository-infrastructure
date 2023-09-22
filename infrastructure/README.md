## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.12.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api_endpoint_url_ssm_parameter"></a> [api\_endpoint\_url\_ssm\_parameter](#module\_api\_endpoint\_url\_ssm\_parameter) | ./modules/ssm_parameter | n/a |
| <a name="module_auth_session_dynamodb_table"></a> [auth\_session\_dynamodb\_table](#module\_auth\_session\_dynamodb\_table) | ./modules/dynamo_db | n/a |
| <a name="module_auth_state_dynamodb_table"></a> [auth\_state\_dynamodb\_table](#module\_auth\_state\_dynamodb\_table) | ./modules/dynamo_db | n/a |
| <a name="module_authoriser-lambda"></a> [authoriser-lambda](#module\_authoriser-lambda) | ./modules/lambda | n/a |
| <a name="module_create-doc-ref-gateway"></a> [create-doc-ref-gateway](#module\_create-doc-ref-gateway) | ./modules/gateway | n/a |
| <a name="module_create-doc-ref-lambda"></a> [create-doc-ref-lambda](#module\_create-doc-ref-lambda) | ./modules/lambda | n/a |
| <a name="module_create-token-lambda"></a> [create-token-lambda](#module\_create-token-lambda) | ./modules/lambda | n/a |
| <a name="module_create_doc_alarm"></a> [create\_doc\_alarm](#module\_create\_doc\_alarm) | ./modules/alarm | n/a |
| <a name="module_create_doc_alarm_topic"></a> [create\_doc\_alarm\_topic](#module\_create\_doc\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_document-manifest-by-nhs-gateway"></a> [document-manifest-by-nhs-gateway](#module\_document-manifest-by-nhs-gateway) | ./modules/gateway | n/a |
| <a name="module_document-manifest-by-nhs-number-lambda"></a> [document-manifest-by-nhs-number-lambda](#module\_document-manifest-by-nhs-number-lambda) | ./modules/lambda | n/a |
| <a name="module_document_manifest_alarm"></a> [document\_manifest\_alarm](#module\_document\_manifest\_alarm) | ./modules/alarm | n/a |
| <a name="module_document_manifest_alarm_topic"></a> [document\_manifest\_alarm\_topic](#module\_document\_manifest\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_document_reference_dynamodb_table"></a> [document\_reference\_dynamodb\_table](#module\_document\_reference\_dynamodb\_table) | ./modules/dynamo_db | n/a |
| <a name="module_jwt_signing_key_private"></a> [jwt\_signing\_key\_private](#module\_jwt\_signing\_key\_private) | ./modules/secrets_manager | n/a |
| <a name="module_jwt_signing_key_public"></a> [jwt\_signing\_key\_public](#module\_jwt\_signing\_key\_public) | ./modules/secrets_manager | n/a |
| <a name="module_lloyd_george_reference_dynamodb_table"></a> [lloyd\_george\_reference\_dynamodb\_table](#module\_lloyd\_george\_reference\_dynamodb\_table) | ./modules/dynamo_db | n/a |
| <a name="module_login_redirect_lambda"></a> [login\_redirect\_lambda](#module\_login\_redirect\_lambda) | ./modules/lambda | n/a |
| <a name="module_logout_redirect_lambda"></a> [logout\_redirect\_lambda](#module\_logout\_redirect\_lambda) | ./modules/lambda | n/a |
| <a name="module_ndr-docker-ecr-ui"></a> [ndr-docker-ecr-ui](#module\_ndr-docker-ecr-ui) | ./modules/ecr/ | n/a |
| <a name="module_ndr-document-store"></a> [ndr-document-store](#module\_ndr-document-store) | ./modules/s3/ | n/a |
| <a name="module_ndr-ecs-fargate"></a> [ndr-ecs-fargate](#module\_ndr-ecs-fargate) | ./modules/ecs | n/a |
| <a name="module_ndr-lloyd-george-store"></a> [ndr-lloyd-george-store](#module\_ndr-lloyd-george-store) | ./modules/s3/ | n/a |
| <a name="module_ndr-vpc-ui"></a> [ndr-vpc-ui](#module\_ndr-vpc-ui) | ./modules/vpc/ | n/a |
| <a name="module_ndr-zip-request-store"></a> [ndr-zip-request-store](#module\_ndr-zip-request-store) | ./modules/s3/ | n/a |
| <a name="module_route53_fargate_ui"></a> [route53\_fargate\_ui](#module\_route53\_fargate\_ui) | ./modules/route53 | n/a |
| <a name="module_search-document-references-gateway"></a> [search-document-references-gateway](#module\_search-document-references-gateway) | ./modules/gateway | n/a |
| <a name="module_search-document-references-lambda"></a> [search-document-references-lambda](#module\_search-document-references-lambda) | ./modules/lambda | n/a |
| <a name="module_search-patient-details-gateway"></a> [search-patient-details-gateway](#module\_search-patient-details-gateway) | ./modules/gateway | n/a |
| <a name="module_search-patient-details-lambda"></a> [search-patient-details-lambda](#module\_search-patient-details-lambda) | ./modules/lambda | n/a |
| <a name="module_search_doc_alarm"></a> [search\_doc\_alarm](#module\_search\_doc\_alarm) | ./modules/alarm | n/a |
| <a name="module_search_doc_alarm_topic"></a> [search\_doc\_alarm\_topic](#module\_search\_doc\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_search_patient_alarm"></a> [search\_patient\_alarm](#module\_search\_patient\_alarm) | ./modules/alarm | n/a |
| <a name="module_search_patient_alarm_topic"></a> [search\_patient\_alarm\_topic](#module\_search\_patient\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_sqs-nems-queue"></a> [sqs-nems-queue](#module\_sqs-nems-queue) | ./modules/sqs | n/a |
| <a name="module_sqs-nems-queue-topic"></a> [sqs-nems-queue-topic](#module\_sqs-nems-queue-topic) | ./modules/sns | n/a |
| <a name="module_sqs-splunk-queue"></a> [sqs-splunk-queue](#module\_sqs-splunk-queue) | ./modules/sqs | n/a |
| <a name="module_zip_store_reference_dynamodb_table"></a> [zip\_store\_reference\_dynamodb\_table](#module\_zip\_store\_reference\_dynamodb\_table) | ./modules/dynamo_db | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_authorizer.repo_authoriser](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_authorizer) | resource |
| [aws_api_gateway_deployment.ndr_api_deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_gateway_response.bad_gateway_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_gateway_response) | resource |
| [aws_api_gateway_gateway_response.unauthorised_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_gateway_response) | resource |
| [aws_api_gateway_method.login_proxy_method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.logout_proxy_method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.token_request_proxy_method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_resource.login_resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.logout_resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.token_request_resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.ndr_doc_store_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_cloudwatch_metric_alarm.repo_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_policy.ssm_policy_authoriser](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm_policy_oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm_policy_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.alarm_notification_kms_key_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth_session_dynamodb_table_name"></a> [auth\_session\_dynamodb\_table\_name](#input\_auth\_session\_dynamodb\_table\_name) | The name of dynamodb table to store user login sessions | `string` | `"AuthSessionReferenceMetadata"` | no |
| <a name="input_auth_state_dynamodb_table_name"></a> [auth\_state\_dynamodb\_table\_name](#input\_auth\_state\_dynamodb\_table\_name) | The name of dynamodb table to store the state values (for CIS2 authorisation) | `string` | `"AuthStateReferenceMetadata"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | This is a list that specifies all the Availability Zones that will have a pair of public and private subnets | `list(string)` | <pre>[<br>  "eu-west-2a",<br>  "eu-west-2b",<br>  "eu-west-2c"<br>]</pre> | no |
| <a name="input_cors_require_credentials"></a> [cors\_require\_credentials](#input\_cors\_require\_credentials) | Sets the value of 'Access-Control-Allow-Credentials' which controls whether auth cookies are needed | `bool` | `true` | no |
| <a name="input_docstore_bucket_name"></a> [docstore\_bucket\_name](#input\_docstore\_bucket\_name) | The name of S3 bucket to store ARF documents | `string` | `"document-store"` | no |
| <a name="input_docstore_dynamodb_table_name"></a> [docstore\_dynamodb\_table\_name](#input\_docstore\_dynamodb\_table\_name) | The name of dynamodb table to store the metadata of ARF documents | `string` | `"DocumentReferenceMetadata"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | n/a | `string` | n/a | yes |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Enable DNS hostnames for VPC | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Enable DNS  support for VPC | `bool` | `true` | no |
| <a name="input_enable_private_routes"></a> [enable\_private\_routes](#input\_enable\_private\_routes) | Controls whether the internet gateway can connect to private subnets | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Tag Variables | `string` | n/a | yes |
| <a name="input_lloyd_george_bucket_name"></a> [lloyd\_george\_bucket\_name](#input\_lloyd\_george\_bucket\_name) | The name of S3 bucket to store Lloyd George documents | `string` | `"lloyd-george-store"` | no |
| <a name="input_lloyd_george_dynamodb_table_name"></a> [lloyd\_george\_dynamodb\_table\_name](#input\_lloyd\_george\_dynamodb\_table\_name) | The name of dynamodb table to store the metadata of Lloyd George documents | `string` | `"LloydGeorgeReferenceMetadata"` | no |
| <a name="input_num_private_subnets"></a> [num\_private\_subnets](#input\_num\_private\_subnets) | Sets the number of private subnets, one per availability zone | `number` | `3` | no |
| <a name="input_num_public_subnets"></a> [num\_public\_subnets](#input\_num\_public\_subnets) | Sets the number of public subnets, one per availability zone | `number` | `3` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | n/a | `string` | n/a | yes |
| <a name="input_zip_store_bucket_name"></a> [zip\_store\_bucket\_name](#input\_zip\_store\_bucket\_name) | n/a | `string` | `"zip-request-store"` | no |
| <a name="input_zip_store_dynamodb_table_name"></a> [zip\_store\_dynamodb\_table\_name](#input\_zip\_store\_dynamodb\_table\_name) | n/a | `string` | `"ZipStoreReferenceMetadata"` | no |

## Outputs

No outputs.
