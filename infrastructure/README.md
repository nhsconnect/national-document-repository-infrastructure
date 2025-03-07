## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.86.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api_endpoint_url_ssm_parameter"></a> [api\_endpoint\_url\_ssm\_parameter](#module\_api\_endpoint\_url\_ssm\_parameter) | ./modules/ssm_parameter | n/a |
| <a name="module_auth_session_dynamodb_table"></a> [auth\_session\_dynamodb\_table](#module\_auth\_session\_dynamodb\_table) | ./modules/dynamo_db | n/a |
| <a name="module_auth_state_dynamodb_table"></a> [auth\_state\_dynamodb\_table](#module\_auth\_state\_dynamodb\_table) | ./modules/dynamo_db | n/a |
| <a name="module_authoriser-alarm"></a> [authoriser-alarm](#module\_authoriser-alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_authoriser-alarm-topic"></a> [authoriser-alarm-topic](#module\_authoriser-alarm-topic) | ./modules/sns | n/a |
| <a name="module_authoriser-lambda"></a> [authoriser-lambda](#module\_authoriser-lambda) | ./modules/lambda | n/a |
| <a name="module_back-channel-logout-gateway"></a> [back-channel-logout-gateway](#module\_back-channel-logout-gateway) | ./modules/gateway | n/a |
| <a name="module_back_channel_logout_alarm"></a> [back\_channel\_logout\_alarm](#module\_back\_channel\_logout\_alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_back_channel_logout_alarm_topic"></a> [back\_channel\_logout\_alarm\_topic](#module\_back\_channel\_logout\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_back_channel_logout_lambda"></a> [back\_channel\_logout\_lambda](#module\_back\_channel\_logout\_lambda) | ./modules/lambda | n/a |
| <a name="module_bulk-upload-alarm"></a> [bulk-upload-alarm](#module\_bulk-upload-alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_bulk-upload-alarm-topic"></a> [bulk-upload-alarm-topic](#module\_bulk-upload-alarm-topic) | ./modules/sns | n/a |
| <a name="module_bulk-upload-lambda"></a> [bulk-upload-lambda](#module\_bulk-upload-lambda) | ./modules/lambda | n/a |
| <a name="module_bulk-upload-metadata-alarm"></a> [bulk-upload-metadata-alarm](#module\_bulk-upload-metadata-alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_bulk-upload-metadata-alarm-topic"></a> [bulk-upload-metadata-alarm-topic](#module\_bulk-upload-metadata-alarm-topic) | ./modules/sns | n/a |
| <a name="module_bulk-upload-metadata-lambda"></a> [bulk-upload-metadata-lambda](#module\_bulk-upload-metadata-lambda) | ./modules/lambda | n/a |
| <a name="module_bulk-upload-report-alarm"></a> [bulk-upload-report-alarm](#module\_bulk-upload-report-alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_bulk-upload-report-alarm-topic"></a> [bulk-upload-report-alarm-topic](#module\_bulk-upload-report-alarm-topic) | ./modules/sns | n/a |
| <a name="module_bulk-upload-report-lambda"></a> [bulk-upload-report-lambda](#module\_bulk-upload-report-lambda) | ./modules/lambda | n/a |
| <a name="module_bulk_upload_report_dynamodb_table"></a> [bulk\_upload\_report\_dynamodb\_table](#module\_bulk\_upload\_report\_dynamodb\_table) | ./modules/dynamo_db | n/a |
| <a name="module_cloudfront-distribution-lg"></a> [cloudfront-distribution-lg](#module\_cloudfront-distribution-lg) | ./modules/cloudfront/ | n/a |
| <a name="module_cloudfront_edge_dynamodb_table"></a> [cloudfront\_edge\_dynamodb\_table](#module\_cloudfront\_edge\_dynamodb\_table) | ./modules/dynamo_db | n/a |
| <a name="module_create-doc-ref-gateway"></a> [create-doc-ref-gateway](#module\_create-doc-ref-gateway) | ./modules/gateway | n/a |
| <a name="module_create-doc-ref-lambda"></a> [create-doc-ref-lambda](#module\_create-doc-ref-lambda) | ./modules/lambda | n/a |
| <a name="module_create-token-gateway"></a> [create-token-gateway](#module\_create-token-gateway) | ./modules/gateway | n/a |
| <a name="module_create-token-lambda"></a> [create-token-lambda](#module\_create-token-lambda) | ./modules/lambda | n/a |
| <a name="module_create_doc_alarm"></a> [create\_doc\_alarm](#module\_create\_doc\_alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_create_doc_alarm_topic"></a> [create\_doc\_alarm\_topic](#module\_create\_doc\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_create_token-alarm"></a> [create\_token-alarm](#module\_create\_token-alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_create_token-alarm_topic"></a> [create\_token-alarm\_topic](#module\_create\_token-alarm\_topic) | ./modules/sns | n/a |
| <a name="module_data-collection-alarm"></a> [data-collection-alarm](#module\_data-collection-alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_data-collection-alarm-topic"></a> [data-collection-alarm-topic](#module\_data-collection-alarm-topic) | ./modules/sns | n/a |
| <a name="module_data-collection-lambda"></a> [data-collection-lambda](#module\_data-collection-lambda) | ./modules/lambda | n/a |
| <a name="module_delete-doc-ref-gateway"></a> [delete-doc-ref-gateway](#module\_delete-doc-ref-gateway) | ./modules/gateway | n/a |
| <a name="module_delete-doc-ref-lambda"></a> [delete-doc-ref-lambda](#module\_delete-doc-ref-lambda) | ./modules/lambda | n/a |
| <a name="module_delete-document-object-alarm"></a> [delete-document-object-alarm](#module\_delete-document-object-alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_delete-document-object-alarm-topic"></a> [delete-document-object-alarm-topic](#module\_delete-document-object-alarm-topic) | ./modules/sns | n/a |
| <a name="module_delete-document-object-lambda"></a> [delete-document-object-lambda](#module\_delete-document-object-lambda) | ./modules/lambda | n/a |
| <a name="module_delete_doc_alarm"></a> [delete\_doc\_alarm](#module\_delete\_doc\_alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_delete_doc_alarm_topic"></a> [delete\_doc\_alarm\_topic](#module\_delete\_doc\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_document-manifest-job-gateway"></a> [document-manifest-job-gateway](#module\_document-manifest-job-gateway) | ./modules/gateway | n/a |
| <a name="module_document-manifest-job-lambda"></a> [document-manifest-job-lambda](#module\_document-manifest-job-lambda) | ./modules/lambda | n/a |
| <a name="module_document_manifest_alarm"></a> [document\_manifest\_alarm](#module\_document\_manifest\_alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_document_manifest_alarm_topic"></a> [document\_manifest\_alarm\_topic](#module\_document\_manifest\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_document_reference_dynamodb_table"></a> [document\_reference\_dynamodb\_table](#module\_document\_reference\_dynamodb\_table) | ./modules/dynamo_db | n/a |
| <a name="module_edge-presign-lambda"></a> [edge-presign-lambda](#module\_edge-presign-lambda) | ./modules/lambda_edge | n/a |
| <a name="module_edge_presign_alarm"></a> [edge\_presign\_alarm](#module\_edge\_presign\_alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_edge_presign_alarm_topic"></a> [edge\_presign\_alarm\_topic](#module\_edge\_presign\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_feature-flags-gateway"></a> [feature-flags-gateway](#module\_feature-flags-gateway) | ./modules/gateway | n/a |
| <a name="module_feature-flags-lambda"></a> [feature-flags-lambda](#module\_feature-flags-lambda) | ./modules/lambda | n/a |
| <a name="module_feature_flags_alarm"></a> [feature\_flags\_alarm](#module\_feature\_flags\_alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_feature_flags_alarm_topic"></a> [feature\_flags\_alarm\_topic](#module\_feature\_flags\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_firewall_waf_v2"></a> [firewall\_waf\_v2](#module\_firewall\_waf\_v2) | ./modules/firewall_waf_v2 | n/a |
| <a name="module_generate-document-manifest-alarm"></a> [generate-document-manifest-alarm](#module\_generate-document-manifest-alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_generate-document-manifest-alarm-topic"></a> [generate-document-manifest-alarm-topic](#module\_generate-document-manifest-alarm-topic) | ./modules/sns | n/a |
| <a name="module_generate-document-manifest-lambda"></a> [generate-document-manifest-lambda](#module\_generate-document-manifest-lambda) | ./modules/lambda | n/a |
| <a name="module_generate-lloyd-george-stitch-alarm"></a> [generate-lloyd-george-stitch-alarm](#module\_generate-lloyd-george-stitch-alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_generate-lloyd-george-stitch-alarm-topic"></a> [generate-lloyd-george-stitch-alarm-topic](#module\_generate-lloyd-george-stitch-alarm-topic) | ./modules/sns | n/a |
| <a name="module_generate-lloyd-george-stitch-lambda"></a> [generate-lloyd-george-stitch-lambda](#module\_generate-lloyd-george-stitch-lambda) | ./modules/lambda | n/a |
| <a name="module_get-doc-nrl-lambda"></a> [get-doc-nrl-lambda](#module\_get-doc-nrl-lambda) | ./modules/lambda | n/a |
| <a name="module_get-report-by-ods-alarm"></a> [get-report-by-ods-alarm](#module\_get-report-by-ods-alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_get-report-by-ods-alarm-topic"></a> [get-report-by-ods-alarm-topic](#module\_get-report-by-ods-alarm-topic) | ./modules/sns | n/a |
| <a name="module_get-report-by-ods-gateway"></a> [get-report-by-ods-gateway](#module\_get-report-by-ods-gateway) | ./modules/gateway | n/a |
| <a name="module_get-report-by-ods-lambda"></a> [get-report-by-ods-lambda](#module\_get-report-by-ods-lambda) | ./modules/lambda | n/a |
| <a name="module_lambda-layer-core"></a> [lambda-layer-core](#module\_lambda-layer-core) | ./modules/lambda_layers | n/a |
| <a name="module_lambda-layer-data"></a> [lambda-layer-data](#module\_lambda-layer-data) | ./modules/lambda_layers | n/a |
| <a name="module_lloyd-george-stitch-gateway"></a> [lloyd-george-stitch-gateway](#module\_lloyd-george-stitch-gateway) | ./modules/gateway | n/a |
| <a name="module_lloyd-george-stitch-lambda"></a> [lloyd-george-stitch-lambda](#module\_lloyd-george-stitch-lambda) | ./modules/lambda | n/a |
| <a name="module_lloyd-george-stitch_alarm"></a> [lloyd-george-stitch\_alarm](#module\_lloyd-george-stitch\_alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_lloyd-george-stitch_topic"></a> [lloyd-george-stitch\_topic](#module\_lloyd-george-stitch\_topic) | ./modules/sns | n/a |
| <a name="module_lloyd_george_reference_dynamodb_table"></a> [lloyd\_george\_reference\_dynamodb\_table](#module\_lloyd\_george\_reference\_dynamodb\_table) | ./modules/dynamo_db | n/a |
| <a name="module_login_redirect-alarm_topic"></a> [login\_redirect-alarm\_topic](#module\_login\_redirect-alarm\_topic) | ./modules/sns | n/a |
| <a name="module_login_redirect_alarm"></a> [login\_redirect\_alarm](#module\_login\_redirect\_alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_login_redirect_lambda"></a> [login\_redirect\_lambda](#module\_login\_redirect\_lambda) | ./modules/lambda | n/a |
| <a name="module_logout-gateway"></a> [logout-gateway](#module\_logout-gateway) | ./modules/gateway | n/a |
| <a name="module_logout_alarm"></a> [logout\_alarm](#module\_logout\_alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_logout_alarm_topic"></a> [logout\_alarm\_topic](#module\_logout\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_logout_lambda"></a> [logout\_lambda](#module\_logout\_lambda) | ./modules/lambda | n/a |
| <a name="module_manage-nrl-pointer-alarm"></a> [manage-nrl-pointer-alarm](#module\_manage-nrl-pointer-alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_manage-nrl-pointer-alarm-topic"></a> [manage-nrl-pointer-alarm-topic](#module\_manage-nrl-pointer-alarm-topic) | ./modules/sns | n/a |
| <a name="module_manage-nrl-pointer-lambda"></a> [manage-nrl-pointer-lambda](#module\_manage-nrl-pointer-lambda) | ./modules/lambda | n/a |
| <a name="module_mns-dlq-alarm-topic"></a> [mns-dlq-alarm-topic](#module\_mns-dlq-alarm-topic) | ./modules/sns | n/a |
| <a name="module_mns-notification-alarm"></a> [mns-notification-alarm](#module\_mns-notification-alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_mns-notification-alarm-topic"></a> [mns-notification-alarm-topic](#module\_mns-notification-alarm-topic) | ./modules/sns | n/a |
| <a name="module_mns-notification-lambda"></a> [mns-notification-lambda](#module\_mns-notification-lambda) | ./modules/lambda | n/a |
| <a name="module_mns_encryption_key"></a> [mns\_encryption\_key](#module\_mns\_encryption\_key) | ./modules/kms | n/a |
| <a name="module_ndr-app-config"></a> [ndr-app-config](#module\_ndr-app-config) | ./modules/app_config | n/a |
| <a name="module_ndr-bulk-staging-store"></a> [ndr-bulk-staging-store](#module\_ndr-bulk-staging-store) | ./modules/s3/ | n/a |
| <a name="module_ndr-docker-ecr-ui"></a> [ndr-docker-ecr-ui](#module\_ndr-docker-ecr-ui) | ./modules/ecr/ | n/a |
| <a name="module_ndr-docker-ecr-weekly-ods-update"></a> [ndr-docker-ecr-weekly-ods-update](#module\_ndr-docker-ecr-weekly-ods-update) | ./modules/ecr/ | n/a |
| <a name="module_ndr-document-store"></a> [ndr-document-store](#module\_ndr-document-store) | ./modules/s3/ | n/a |
| <a name="module_ndr-ecs-container-port-ssm-parameter"></a> [ndr-ecs-container-port-ssm-parameter](#module\_ndr-ecs-container-port-ssm-parameter) | ./modules/ssm_parameter | n/a |
| <a name="module_ndr-ecs-fargate-app"></a> [ndr-ecs-fargate-app](#module\_ndr-ecs-fargate-app) | ./modules/ecs | n/a |
| <a name="module_ndr-ecs-fargate-ods-update"></a> [ndr-ecs-fargate-ods-update](#module\_ndr-ecs-fargate-ods-update) | ./modules/ecs | n/a |
| <a name="module_ndr-feedback-mailbox"></a> [ndr-feedback-mailbox](#module\_ndr-feedback-mailbox) | ./modules/ses | n/a |
| <a name="module_ndr-lloyd-george-store"></a> [ndr-lloyd-george-store](#module\_ndr-lloyd-george-store) | ./modules/s3/ | n/a |
| <a name="module_ndr-vpc-ui"></a> [ndr-vpc-ui](#module\_ndr-vpc-ui) | ./modules/vpc/ | n/a |
| <a name="module_ndr-zip-request-store"></a> [ndr-zip-request-store](#module\_ndr-zip-request-store) | ./modules/s3/ | n/a |
| <a name="module_nems-message-lambda"></a> [nems-message-lambda](#module\_nems-message-lambda) | ./modules/lambda | n/a |
| <a name="module_nems-message-lambda-alarm"></a> [nems-message-lambda-alarm](#module\_nems-message-lambda-alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_nems-message-lambda-alarm-topic"></a> [nems-message-lambda-alarm-topic](#module\_nems-message-lambda-alarm-topic) | ./modules/sns | n/a |
| <a name="module_nrl-dlq-alarm-topic"></a> [nrl-dlq-alarm-topic](#module\_nrl-dlq-alarm-topic) | ./modules/sns | n/a |
| <a name="module_pdf-stitching-alarm-topic"></a> [pdf-stitching-alarm-topic](#module\_pdf-stitching-alarm-topic) | ./modules/sns | n/a |
| <a name="module_pdf-stitching-lambda"></a> [pdf-stitching-lambda](#module\_pdf-stitching-lambda) | ./modules/lambda | n/a |
| <a name="module_pdf-stitching-lambda-alarms"></a> [pdf-stitching-lambda-alarms](#module\_pdf-stitching-lambda-alarms) | ./modules/lambda_alarms | n/a |
| <a name="module_route53_fargate_ui"></a> [route53\_fargate\_ui](#module\_route53\_fargate\_ui) | ./modules/route53 | n/a |
| <a name="module_search-document-references-gateway"></a> [search-document-references-gateway](#module\_search-document-references-gateway) | ./modules/gateway | n/a |
| <a name="module_search-document-references-lambda"></a> [search-document-references-lambda](#module\_search-document-references-lambda) | ./modules/lambda | n/a |
| <a name="module_search-patient-details-gateway"></a> [search-patient-details-gateway](#module\_search-patient-details-gateway) | ./modules/gateway | n/a |
| <a name="module_search-patient-details-lambda"></a> [search-patient-details-lambda](#module\_search-patient-details-lambda) | ./modules/lambda | n/a |
| <a name="module_search_doc_alarm"></a> [search\_doc\_alarm](#module\_search\_doc\_alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_search_doc_alarm_topic"></a> [search\_doc\_alarm\_topic](#module\_search\_doc\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_search_patient_alarm"></a> [search\_patient\_alarm](#module\_search\_patient\_alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_search_patient_alarm_topic"></a> [search\_patient\_alarm\_topic](#module\_search\_patient\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_send-feedback-alarm"></a> [send-feedback-alarm](#module\_send-feedback-alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_send-feedback-alarm-topic"></a> [send-feedback-alarm-topic](#module\_send-feedback-alarm-topic) | ./modules/sns | n/a |
| <a name="module_send-feedback-gateway"></a> [send-feedback-gateway](#module\_send-feedback-gateway) | ./modules/gateway | n/a |
| <a name="module_send-feedback-lambda"></a> [send-feedback-lambda](#module\_send-feedback-lambda) | ./modules/lambda | n/a |
| <a name="module_sns-nems-queue-topic"></a> [sns-nems-queue-topic](#module\_sns-nems-queue-topic) | ./modules/sns | n/a |
| <a name="module_sns_encryption_key"></a> [sns\_encryption\_key](#module\_sns\_encryption\_key) | ./modules/kms | n/a |
| <a name="module_sqs-lg-bulk-upload-invalid-queue"></a> [sqs-lg-bulk-upload-invalid-queue](#module\_sqs-lg-bulk-upload-invalid-queue) | ./modules/sqs | n/a |
| <a name="module_sqs-lg-bulk-upload-metadata-queue"></a> [sqs-lg-bulk-upload-metadata-queue](#module\_sqs-lg-bulk-upload-metadata-queue) | ./modules/sqs | n/a |
| <a name="module_sqs-mns-notification-queue"></a> [sqs-mns-notification-queue](#module\_sqs-mns-notification-queue) | ./modules/sqs | n/a |
| <a name="module_sqs-nems-queue"></a> [sqs-nems-queue](#module\_sqs-nems-queue) | ./modules/sqs | n/a |
| <a name="module_sqs-nrl-queue"></a> [sqs-nrl-queue](#module\_sqs-nrl-queue) | ./modules/sqs | n/a |
| <a name="module_sqs-splunk-queue"></a> [sqs-splunk-queue](#module\_sqs-splunk-queue) | ./modules/sqs | n/a |
| <a name="module_sqs-stitching-queue"></a> [sqs-stitching-queue](#module\_sqs-stitching-queue) | ./modules/sqs | n/a |
| <a name="module_statistical-report-alarm"></a> [statistical-report-alarm](#module\_statistical-report-alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_statistical-report-alarm-topic"></a> [statistical-report-alarm-topic](#module\_statistical-report-alarm-topic) | ./modules/sns | n/a |
| <a name="module_statistical-report-lambda"></a> [statistical-report-lambda](#module\_statistical-report-lambda) | ./modules/lambda | n/a |
| <a name="module_statistical-reports-store"></a> [statistical-reports-store](#module\_statistical-reports-store) | ./modules/s3/ | n/a |
| <a name="module_statistics_dynamodb_table"></a> [statistics\_dynamodb\_table](#module\_statistics\_dynamodb\_table) | ./modules/dynamo_db | n/a |
| <a name="module_stitch_metadata_reference_dynamodb_table"></a> [stitch\_metadata\_reference\_dynamodb\_table](#module\_stitch\_metadata\_reference\_dynamodb\_table) | ./modules/dynamo_db | n/a |
| <a name="module_stitching-dlq-alarm-topic"></a> [stitching-dlq-alarm-topic](#module\_stitching-dlq-alarm-topic) | ./modules/sns | n/a |
| <a name="module_unstitched_lloyd_george_reference_dynamodb_table"></a> [unstitched\_lloyd\_george\_reference\_dynamodb\_table](#module\_unstitched\_lloyd\_george\_reference\_dynamodb\_table) | ./modules/dynamo_db | n/a |
| <a name="module_update-upload-state-gateway"></a> [update-upload-state-gateway](#module\_update-upload-state-gateway) | ./modules/gateway | n/a |
| <a name="module_update-upload-state-lambda"></a> [update-upload-state-lambda](#module\_update-upload-state-lambda) | ./modules/lambda | n/a |
| <a name="module_update_upload_state_alarm"></a> [update\_upload\_state\_alarm](#module\_update\_upload\_state\_alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_update_upload_state_alarm_topic"></a> [update\_upload\_state\_alarm\_topic](#module\_update\_upload\_state\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_upload_confirm_result_alarm"></a> [upload\_confirm\_result\_alarm](#module\_upload\_confirm\_result\_alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_upload_confirm_result_alarm_topic"></a> [upload\_confirm\_result\_alarm\_topic](#module\_upload\_confirm\_result\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_upload_confirm_result_gateway"></a> [upload\_confirm\_result\_gateway](#module\_upload\_confirm\_result\_gateway) | ./modules/gateway | n/a |
| <a name="module_upload_confirm_result_lambda"></a> [upload\_confirm\_result\_lambda](#module\_upload\_confirm\_result\_lambda) | ./modules/lambda | n/a |
| <a name="module_virus_scan_result_alarm"></a> [virus\_scan\_result\_alarm](#module\_virus\_scan\_result\_alarm) | ./modules/lambda_alarms | n/a |
| <a name="module_virus_scan_result_alarm_topic"></a> [virus\_scan\_result\_alarm\_topic](#module\_virus\_scan\_result\_alarm\_topic) | ./modules/sns | n/a |
| <a name="module_virus_scan_result_gateway"></a> [virus\_scan\_result\_gateway](#module\_virus\_scan\_result\_gateway) | ./modules/gateway | n/a |
| <a name="module_virus_scan_result_lambda"></a> [virus\_scan\_result\_lambda](#module\_virus\_scan\_result\_lambda) | ./modules/lambda | n/a |
| <a name="module_zip_store_reference_dynamodb_table"></a> [zip\_store\_reference\_dynamodb\_table](#module\_zip\_store\_reference\_dynamodb\_table) | ./modules/dynamo_db | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_api_key.apim](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_api_key) | resource |
| [aws_api_gateway_authorizer.repo_authoriser](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_authorizer) | resource |
| [aws_api_gateway_base_path_mapping.api_mapping](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_base_path_mapping) | resource |
| [aws_api_gateway_deployment.ndr_api_deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_domain_name.custom_api_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_domain_name) | resource |
| [aws_api_gateway_gateway_response.bad_gateway_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_gateway_response) | resource |
| [aws_api_gateway_gateway_response.unauthorised_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_gateway_response) | resource |
| [aws_api_gateway_integration.get_document_reference_mock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.get_document_reference_mock_200_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_integration_response.get_document_reference_mock_401_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_integration_response.get_document_reference_mock_403_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_integration_response.get_document_reference_mock_404_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.get_document_reference](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.login_proxy_method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.sandbox_get_document_reference](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.response_200](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_response.response_401](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_response.response_403](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_response.response_404](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_resource.auth_resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.get_document_reference](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.login_resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.nrl_sandbox](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.sandbox_get_document_reference](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.sandbox_get_document_reference_path_parameter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.ndr_doc_store_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.ndr_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_api_gateway_usage_plan.apim](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan) | resource |
| [aws_api_gateway_usage_plan_key.apim](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan_key) | resource |
| [aws_backup_plan.cross_account_backup_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_plan.s3_continuous_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_selection.cross_account_backup_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_selection.s3_continuous_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_vault.backup_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_cloudwatch_event_rule.bulk_upload_metadata_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.bulk_upload_report_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.data_collection_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.statistical_report_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.bulk_upload_metadata_schedule_event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.bulk_upload_report_schedule_event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.data_collection_schedule_event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.statistical_report_schedule_event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.mesh_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_metric_filter.edge_presign_error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_metric_filter.error_log_metric_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_metric_filter.inbox_message_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.api_gateway_alarm_4XX](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.api_gateway_alarm_5XX](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.edge_presign_lambda_error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.error_log_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.inbox-messages-not-consumed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.msn_dlq_new_message](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.nrl_dlq_new_messages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.sns_topic_error_log_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.stitching_dlq_new_messages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cognito_identity_pool.cloudwatch_rum](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool) | resource |
| [aws_cognito_identity_pool_roles_attachment.cloudwatch_rum](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool_roles_attachment) | resource |
| [aws_ecs_cluster.mesh-forwarder-ecs-cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.mesh_forwarder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.forwarder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.cloudwatch_log_query_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cloudwatch_rum_cognito_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.copy_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.dynamodb_policy_scan_bulk_report](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.dynamodb_stream_delete_object_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.dynamodb_stream_manifest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.dynamodb_stream_stitch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.kms_mns_lambda_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_audit_splunk_sqs_queue_send_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_document_data_policy_for_get_doc_ref_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_document_data_policy_for_manifest_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_document_data_policy_for_ods_report_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_document_data_policy_for_stitch_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_document_data_policy_put_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ses_send_email_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm_policy_authoriser](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm_policy_oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm_policy_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cognito_unauthenticated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.create_post_presign_url_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cross_account_backup_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.manifest_presign_url_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.mesh_forwarder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.nrl_get_doc_presign_url_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ods_report_presign_url_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ods_weekly_update_ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ods_weekly_update_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.s3_backup_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.sns_failure_feedback_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.splunk_sqs_forwarder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.stitch_presign_url_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.mesh_ecr_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.mesh_kms_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.mesh_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.mesh_sns_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.mesh_ssm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.sns_failure_feedback](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.splunk_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.backup_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_rum_cognito_unauth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.create_post_presign_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cross_account_backup_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cross_account_copy_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cross_account_restore_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cross_account_s3_backup_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_stitch-lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.manifest_presign_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.nrl_get_doc_presign_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ods_report_presign_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ods_weekly_app_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ods_weekly_cloudwatch_log_query_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ods_weekly_document_reference_dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ods_weekly_document_store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ods_weekly_lloyd_george_reference_dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ods_weekly_lloyd_george_store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ods_weekly_ssm_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ods_weekly_statistical_reports_store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ods_weekly_statistics_dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ods_weekly_update_ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.policy_audit_get-report-by-ods-lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.policy_audit_search-patient-details-lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.policy_audit_token_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.policy_generate_manifest_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.policy_generate_stitch_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.policy_manifest_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.restore_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_backup_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_cross_account_restore_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_restore_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.stitch_presign_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_event_source_mapping.bulk_upload_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.document_reference_dynamodb_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.dynamodb_stream_manifest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.dynamodb_stream_stitch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.lloyd_george_dynamodb_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.mns_notification_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.nems_message_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.nrl_pointer_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.pdf-stitching-lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_permission.bulk_upload_metadata_schedule_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.bulk_upload_report_schedule_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.data_collection_schedule_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.statistical_report_schedule_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_rum_app_monitor.ndr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rum_app_monitor) | resource |
| [aws_s3_bucket.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.doc-store-lifecycle-rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.lg-lifecycle-rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.staging-store-lifecycle-rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.logs_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_scheduler_schedule.ods_weekly_update_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_security_group.ndr_mesh_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_sns_topic.alarm_notifications_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.alarm_notifications_sns_topic_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sqs_queue_policy.mns_sqs_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_sqs_queue_policy.nems_events_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_ssm_parameter.nems_events_observability](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.nems_events_topic_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.sns_sqs_kms_key_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_vpc_security_group_egress_rule.ndr_ecs_sg_egress_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.ndr_ecs_sg_egress_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ndr_ecs_sg_ingress_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ndr_ecs_sg_ingress_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_wafv2_web_acl_association.web_acl_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecr_repository.mesh_s3_forwarder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository) | data source |
| [aws_elb_service_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_iam_policy_document.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role_policy_for_create_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role_policy_for_get_doc_ref_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role_policy_for_manifest_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role_policy_for_ods_report_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role_policy_for_stitch_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.backup_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecr_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs-assume-role-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.logs_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.logs_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_failure_feedback_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_service_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.splunk_trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sqs_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.apim_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.backup_target_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.cloud_security_notification_email_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.end_user_ods_code](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.mns_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.splunk_trusted_principal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.target_backup_vault_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth_session_dynamodb_table_name"></a> [auth\_session\_dynamodb\_table\_name](#input\_auth\_session\_dynamodb\_table\_name) | The name of the dynamodb table to store user login sessions | `string` | `"AuthSessionReferenceMetadata"` | no |
| <a name="input_auth_state_dynamodb_table_name"></a> [auth\_state\_dynamodb\_table\_name](#input\_auth\_state\_dynamodb\_table\_name) | The name of the dynamodb table to store the state values (for CIS2 authorisation) | `string` | `"AuthStateReferenceMetadata"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | This is a list that specifies all the Availability Zones that will have a pair of public and private subnets | `list(string)` | <pre>[<br/>  "eu-west-2a",<br/>  "eu-west-2b",<br/>  "eu-west-2c"<br/>]</pre> | no |
| <a name="input_bulk_upload_report_dynamodb_table_name"></a> [bulk\_upload\_report\_dynamodb\_table\_name](#input\_bulk\_upload\_report\_dynamodb\_table\_name) | The name of the dynamodb table to store bulk upload status | `string` | `"BulkUploadReport"` | no |
| <a name="input_certificate_domain"></a> [certificate\_domain](#input\_certificate\_domain) | n/a | `string` | n/a | yes |
| <a name="input_certificate_subdomain_name_prefix"></a> [certificate\_subdomain\_name\_prefix](#input\_certificate\_subdomain\_name\_prefix) | Prefix to add to subdomains on certification configurations, dev envs use api-{env}, prod envs use api.{env} | `string` | `"api-"` | no |
| <a name="input_cloud_only_service_instances"></a> [cloud\_only\_service\_instances](#input\_cloud\_only\_service\_instances) | n/a | `number` | `1` | no |
| <a name="input_cloudfront_edge_table_name"></a> [cloudfront\_edge\_table\_name](#input\_cloudfront\_edge\_table\_name) | The name of the dynamodb table to store the presigned url reference of CloudFront requests | `string` | `"CloudFrontEdgeReference"` | no |
| <a name="input_cloudwatch_alarm_evaluation_periods"></a> [cloudwatch\_alarm\_evaluation\_periods](#input\_cloudwatch\_alarm\_evaluation\_periods) | n/a | `any` | n/a | yes |
| <a name="input_disable_message_header_validation"></a> [disable\_message\_header\_validation](#input\_disable\_message\_header\_validation) | if true then relaxes the restrictions on MESH message headers | `string` | `"true"` | no |
| <a name="input_docstore_bucket_name"></a> [docstore\_bucket\_name](#input\_docstore\_bucket\_name) | The name of the S3 bucket to store ARF documents | `string` | `"ndr-document-store"` | no |
| <a name="input_docstore_dynamodb_table_name"></a> [docstore\_dynamodb\_table\_name](#input\_docstore\_dynamodb\_table\_name) | The name of the dynamodb table to store the metadata of ARF documents | `string` | `"DocumentReferenceMetadata"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | n/a | `string` | n/a | yes |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Enable DNS hostnames for VPC | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Enable DNS  support for VPC | `bool` | `true` | no |
| <a name="input_enable_private_routes"></a> [enable\_private\_routes](#input\_enable\_private\_routes) | Controls whether the internet gateway can connect to private subnets | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Tag Variables | `string` | n/a | yes |
| <a name="input_lloyd_george_bucket_name"></a> [lloyd\_george\_bucket\_name](#input\_lloyd\_george\_bucket\_name) | The name of the S3 bucket to store Lloyd George documents | `string` | `"lloyd-george-store"` | no |
| <a name="input_lloyd_george_dynamodb_table_name"></a> [lloyd\_george\_dynamodb\_table\_name](#input\_lloyd\_george\_dynamodb\_table\_name) | The name of the dynamodb table to store the metadata of Lloyd George documents | `string` | `"LloydGeorgeReferenceMetadata"` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | n/a | `string` | `"debug"` | no |
| <a name="input_mesh_ca_cert_ssm_param_name"></a> [mesh\_ca\_cert\_ssm\_param\_name](#input\_mesh\_ca\_cert\_ssm\_param\_name) | Name of SSM parameter containing MESH CA certificate | `string` | n/a | yes |
| <a name="input_mesh_client_cert_ssm_param_name"></a> [mesh\_client\_cert\_ssm\_param\_name](#input\_mesh\_client\_cert\_ssm\_param\_name) | Name of SSM parameter containing MESH client certificate | `string` | n/a | yes |
| <a name="input_mesh_client_key_ssm_param_name"></a> [mesh\_client\_key\_ssm\_param\_name](#input\_mesh\_client\_key\_ssm\_param\_name) | Name of SSM parameter containing MESH client key | `string` | n/a | yes |
| <a name="input_mesh_component_name"></a> [mesh\_component\_name](#input\_mesh\_component\_name) | n/a | `string` | `"mesh-forwarder"` | no |
| <a name="input_mesh_mailbox_ssm_param_name"></a> [mesh\_mailbox\_ssm\_param\_name](#input\_mesh\_mailbox\_ssm\_param\_name) | Name of SSM parameter containing MESH mailbox name | `string` | n/a | yes |
| <a name="input_mesh_password_ssm_param_name"></a> [mesh\_password\_ssm\_param\_name](#input\_mesh\_password\_ssm\_param\_name) | Name of SSM parameter containing MESH mailbox password | `string` | n/a | yes |
| <a name="input_mesh_shared_key_ssm_param_name"></a> [mesh\_shared\_key\_ssm\_param\_name](#input\_mesh\_shared\_key\_ssm\_param\_name) | Name of SSM parameter containing MESH shared key | `string` | n/a | yes |
| <a name="input_mesh_url"></a> [mesh\_url](#input\_mesh\_url) | URL of MESH service | `string` | n/a | yes |
| <a name="input_message_destination"></a> [message\_destination](#input\_message\_destination) | n/a | `string` | `"sns"` | no |
| <a name="input_nrl_api_endpoint_suffix"></a> [nrl\_api\_endpoint\_suffix](#input\_nrl\_api\_endpoint\_suffix) | n/a | `string` | `"api.service.nhs.uk/record-locator/producer/FHIR/R4/DocumentReference"` | no |
| <a name="input_num_private_subnets"></a> [num\_private\_subnets](#input\_num\_private\_subnets) | Sets the number of private subnets, one per availability zone | `number` | `3` | no |
| <a name="input_num_public_subnets"></a> [num\_public\_subnets](#input\_num\_public\_subnets) | Sets the number of public subnets, one per availability zone | `number` | `3` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | n/a | `string` | n/a | yes |
| <a name="input_poll_frequency"></a> [poll\_frequency](#input\_poll\_frequency) | n/a | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"eu-west-2"` | no |
| <a name="input_staging_store_bucket_name"></a> [staging\_store\_bucket\_name](#input\_staging\_store\_bucket\_name) | n/a | `string` | `"staging-bulk-store"` | no |
| <a name="input_standalone_vpc_ig_tag"></a> [standalone\_vpc\_ig\_tag](#input\_standalone\_vpc\_ig\_tag) | This is the tag assigned to the standalone vpc internet gateway that should be created manaully before the first run of the infrastructure | `string` | n/a | yes |
| <a name="input_standalone_vpc_tag"></a> [standalone\_vpc\_tag](#input\_standalone\_vpc\_tag) | This is the tag assigned to the standalone vpc that should be created manaully before the first run of the infrastructure | `string` | n/a | yes |
| <a name="input_statistical_reports_bucket_name"></a> [statistical\_reports\_bucket\_name](#input\_statistical\_reports\_bucket\_name) | The name of the S3 bucket to store weekly generated statistical reports | `string` | `"statistical-reports"` | no |
| <a name="input_statistics_dynamodb_table_name"></a> [statistics\_dynamodb\_table\_name](#input\_statistics\_dynamodb\_table\_name) | The name of the dynamodb table to store application statistics | `string` | `"ApplicationStatistics"` | no |
| <a name="input_stitch_metadata_dynamodb_table_name"></a> [stitch\_metadata\_dynamodb\_table\_name](#input\_stitch\_metadata\_dynamodb\_table\_name) | n/a | `string` | `"LloydGeorgeStitchJobMetadata"` | no |
| <a name="input_unstitched_lloyd_george_dynamodb_table_name"></a> [unstitched\_lloyd\_george\_dynamodb\_table\_name](#input\_unstitched\_lloyd\_george\_dynamodb\_table\_name) | The name of the dynamodb table to store the metadata of un-stitched Lloyd George documents | `string` | `"UnstitchedLloydGeorgeReferenceMetadata"` | no |
| <a name="input_zip_store_bucket_name"></a> [zip\_store\_bucket\_name](#input\_zip\_store\_bucket\_name) | n/a | `string` | `"zip-request-store"` | no |
| <a name="input_zip_store_dynamodb_table_name"></a> [zip\_store\_dynamodb\_table\_name](#input\_zip\_store\_dynamodb\_table\_name) | n/a | `string` | `"ZipStoreReferenceMetadata"` | no |

## Outputs

No outputs.
