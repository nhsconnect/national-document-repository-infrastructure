moved {
  from = module.document_reference_gateway
  to   = module.create_document_reference_gateway
}

#PRME-125
moved {
  from = module.upload_confirm_result_gateway
  to   = module.document-status-check-gateway
}

moved {
  from = module.upload_confirm_result_lambda
  to   = module.document-status-check-lambda
}

moved {
  from = module.upload_confirm_result_alarm
  to   = module.document-status-check-alarm
}

moved {
  from = module.upload_confirm_result_alarm_topic
  to   = module.document-status-check-alarm-topic
}

#NDR-233
moved {
  from = module.search-document-references-fhir-lambda.aws_iam_role.lambda_execution_role
  to   = module.search_document_references_fhir_lambda.aws_iam_role.lambda_execution_role
}

moved {
  from = module.search-document-references-fhir-lambda.aws_cloudwatch_log_group.lambda_logs[0]
  to   = module.search_document_references_fhir_lambda.aws_cloudwatch_log_group.lambda_logs[0]
}

moved {
  from = module.search-document-references-fhir-lambda.aws_lambda_function.lambda
  to   = module.search_document_references_fhir_lambda.aws_lambda_function.lambda
}

moved {
  from = module.search-document-references-fhir-lambda.aws_kms_alias.lambda
  to   = module.search_document_references_fhir_lambda.aws_kms_alias.lambda
}

moved {
  from = module.search-document-references-fhir-lambda.aws_iam_policy.combined_policies
  to   = module.search_document_references_fhir_lambda.aws_iam_policy.combined_policies
}

moved {
  from = module.search-document-references-fhir-lambda.aws_lambda_permission.lambda_permission[0]
  to   = module.search_document_references_fhir_lambda.aws_lambda_permission.lambda_permission[0]
}

moved {
  from = module.post-document-references-fhir-lambda.aws_iam_role.lambda_execution_role
  to   = module.post_document_references_fhir_lambda.aws_iam_role.lambda_execution_role
}

moved {
  from = module.post-document-references-fhir-lambda.aws_cloudwatch_log_group.lambda_logs[0]
  to   = module.post_document_references_fhir_lambda.aws_cloudwatch_log_group.lambda_logs[0]
}

moved {
  from = module.post-document-references-fhir-lambda.aws_lambda_function.lambda
  to   = module.post_document_references_fhir_lambda.aws_lambda_function.lambda
}

moved {
  from = module.post-document-references-fhir-lambda.aws_kms_alias.lambda
  to   = module.post_document_references_fhir_lambda.aws_kms_alias.lambda
}

moved {
  from = module.post-document-references-fhir-lambda.aws_iam_policy.combined_policies
  to   = module.post_document_references_fhir_lambda.aws_iam_policy.combined_policies
}

moved {
  from = module.post-document-references-fhir-lambda.aws_lambda_permission.lambda_permission[0]
  to   = module.post_document_references_fhir_lambda.aws_lambda_permission.lambda_permission[0]
}

moved {
  from = module.get-doc-fhir-lambda.aws_iam_role.lambda_execution_role
  to   = module.get_document_reference_fhir_lambda.aws_iam_role.lambda_execution_role
}

moved {
  from = module.get-doc-fhir-lambda.aws_cloudwatch_log_group.lambda_logs[0]
  to   = module.get_document_reference_fhir_lambda.aws_cloudwatch_log_group.lambda_logs[0]
}

moved {
  from = module.get-doc-fhir-lambda.aws_lambda_function.lambda
  to   = module.get_document_reference_fhir_lambda.aws_lambda_function.lambda
}
moved {
  from = module.get-doc-fhir-lambda.aws_kms_alias.lambda
  to   = module.get_document_reference_fhir_lambda.aws_kms_alias.lambda
}
moved {
  from = module.get-doc-fhir-lambda.aws_iam_policy.combined_policies
  to   = module.get_document_reference_fhir_lambda.aws_iam_policy.combined_policies
}

moved {
  from = module.get-doc-fhir-lambda.aws_lambda_permission.lambda_permission[0]
  to   = module.get_document_reference_fhir_lambda.aws_lambda_permission.lambda_permission[0]
}
