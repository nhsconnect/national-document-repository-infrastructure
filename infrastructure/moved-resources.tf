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

#NDR-205

moved {
  from = module.post-document-references-fhir-lambda[0].aws_iam_role.lambda_execution_role
  to   = module.post-document-references-fhir-lambda.aws_iam_role.lambda_execution_role
}

moved {
  from = module.post-document-references-fhir-lambda[0].aws_cloudwatch_log_group.lambda_logs[0]
  to   = module.post-document-references-fhir-lambda.aws_cloudwatch_log_group.lambda_logs[0]
}

moved {
  from = module.post-document-references-fhir-lambda[0].aws_lambda_function.lambda
  to   = module.post-document-references-fhir-lambda.aws_lambda_function.lambda
}

moved {
  from = module.post-document-references-fhir-lambda[0].aws_kms_alias.lambda
  to   = module.post-document-references-fhir-lambda.aws_kms_alias.lambda
}
moved {
  from = module.post-document-references-fhir-lambda[0].aws_iam_policy.combined_policies
  to   = module.post-document-references-fhir-lambda.aws_iam_policy.combined_policies
}

moved {
  from = module.post-document-references-fhir-lambda[0].aws_lambda_permission.lambda_permission[0]
  to   = module.post-document-references-fhir-lambda.aws_lambda_permission.lambda_permission[0]
}

moved {
  from = module.get-doc-fhir-lambda[0].aws_iam_role.lambda_execution_role
  to   = module.get-doc-fhir-lambda.aws_iam_role.lambda_execution_role
}

moved {
  from = module.get-doc-fhir-lambda[0].aws_cloudwatch_log_group.lambda_logs[0]
  to   = module.get-doc-fhir-lambda.aws_cloudwatch_log_group.lambda_logs[0]
}

moved {
  from = module.get-doc-fhir-lambda[0].aws_lambda_function.lambda
  to   = module.get-doc-fhir-lambda.aws_lambda_function.lambda
}
moved {
  from = module.get-doc-fhir-lambda[0].aws_kms_alias.lambda
  to   = module.get-doc-fhir-lambda.aws_kms_alias.lambda
}
moved {
  from = module.get-doc-fhir-lambda[0].aws_iam_policy.combined_policies
  to   = module.get-doc-fhir-lambda.aws_iam_policy.combined_policies
}

moved {
  from = module.get-doc-fhir-lambda[0].aws_lambda_permission.lambda_permission[0]
  to   = module.get-doc-fhir-lambda.aws_lambda_permission.lambda_permission[0]
}

#PRMP-166
moved {
  from = module.create_document_reference_gateway
  to   = module.document_reference_gateway
}