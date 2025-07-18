# resource "aws_cloudwatch_metric_alarm" "search_patient_error_count_low" {
#   alarm_name          = "search_patient_error_count_low"
#   alarm_description   = "Triggers when search patient lambda error count is between 1 and 3 within 2mins"
#   comparison_operator = "GreaterThanThreshold"
#   threshold           = 0
#   evaluation_periods  = 1
#   alarm_actions       = [module.search_patient_alarm_topic.arn]
#   ok_actions          = [module.search_patient_alarm_topic.arn]
#   tags = {
#     is_kpi       = "true"
#     alarm_group  = module.search-patient-details-lambda.function_name
#     alarm_metric = "Errors"
#     severity     = "low"
#   }
#   metric_query {
#     id          = "error"
#     label       = "error count for search patient, low if between 1 and 3"
#     return_data = true
#     expression  = "IF(m1 >= 1 AND m1 <= 3, 1, 0)"
#   }
#
#   metric_query {
#     id = "m1"
#
#     metric {
#       metric_name = "Errors"
#       namespace   = "AWS/Lambda"
#       period      = 120
#       stat        = "Sum"
#       dimensions = {
#         FunctionName = module.search-patient-details-lambda.function_name
#       }
#     }
#   }
# }
#
# resource "aws_cloudwatch_metric_alarm" "search_patient_error_count_medium" {
#   alarm_name          = "search_patient_error_count_medium"
#   alarm_description   = "Triggers when search patient lambda error count is between 4 and 6 within 2mins"
#   comparison_operator = "GreaterThanThreshold"
#   threshold           = 0
#   evaluation_periods  = 1
#   alarm_actions       = [module.search_patient_alarm_topic.arn]
#   ok_actions          = [module.search_patient_alarm_topic.arn]
#   tags = {
#     is_kpi       = "true"
#     alarm_group  = module.search-patient-details-lambda.function_name
#     alarm_metric = "Errors"
#     severity     = "medium"
#   }
#   metric_query {
#     id          = "error"
#     label       = "error count for search patient, medium if between 4 and 6"
#     return_data = true
#     expression  = "IF(m1 >= 4 AND m1 <= 6, 1, 0)"
#   }
#
#   metric_query {
#     id = "m1"
#
#     metric {
#       metric_name = "Errors"
#       namespace   = "AWS/Lambda"
#       period      = 120
#       stat        = "Sum"
#       dimensions = {
#         FunctionName = module.search-patient-details-lambda.function_name
#       }
#     }
#   }
# }
#
# resource "aws_cloudwatch_metric_alarm" "search_patient_error_count_high" {
#   alarm_name          = "search_patient_error_count_high"
#   alarm_description   = "Triggers when search patient lambda error count is 7 or above"
#   comparison_operator = "GreaterThanThreshold"
#   threshold           = 0
#   evaluation_periods  = 1
#   alarm_actions       = [module.search_patient_alarm_topic.arn]
#   ok_actions          = [module.search_patient_alarm_topic.arn]
#   tags = {
#     is_kpi       = "true"
#     alarm_group  = module.search-patient-details-lambda.function_name
#     alarm_metric = "Errors"
#     severity     = "high"
#   }
#   metric_query {
#     id          = "error"
#     label       = "error count for search patient, high if 7 or above"
#     return_data = true
#     expression  = "IF(m1 >= 7, 1, 0)"
#   }
#
#   metric_query {
#     id = "m1"
#
#     metric {
#       metric_name = "Errors"
#       namespace   = "AWS/Lambda"
#       period      = 120
#       stat        = "Sum"
#       dimensions = {
#         FunctionName = module.search-patient-details-lambda.function_name
#       }
#     }
#   }
# }

# resource "aws_sns_topic_subscription" "im_alerting_search_patient" {
#   endpoint  = module.im-alerting-lambda.lambda_arn
#   protocol  = "lambda"
#   topic_arn = module.search_patient_alarm_topic.arn
# }
#
# resource "aws_lambda_permission" "im_alerting_invoke_with_search_patient_sns" {
#   statement_id  = "AllowExecutionFromSeachPatientAlarmSNS"
#   action        = "lambda:InvokeFunction"
#   function_name = module.im-alerting-lambda.lambda_arn
#   principal     = "sns.amazonaws.com"
#   source_arn    = module.search_patient_alarm_topic.arn
# }