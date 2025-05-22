# Lambda CloudWatch Alarms Module

This Terraform module provisions CloudWatch metric alarms for a single AWS Lambda function. It creates alarms for key operational metrics such as duration, error rate, and memory usage, which are critical for monitoring performance and availability.

The alarms can trigger custom actions such as SNS notifications or automated responses and are designed to be easily integrated into production observability setups.

---

## Features

- [x] CloudWatch alarm for high **duration** (exec time vs. timeout)
- [x] CloudWatch alarm for **errors** (failed invocations)
- [x] CloudWatch alarm for high **memory usage**
- [x] Configurable `alarm_actions` and `ok_actions`
- [x] Supports custom CloudWatch namespace (default: `AWS/Lambda`)

---

## Usage

```hcl
module "lambda_alarms" {
  source = "./modules/lambda-alarms"

  # Required: The name of the Lambda function to monitor
  lambda_function_name = "my-lambda-function"

  # Required: Short identifier used in alarm naming
  lambda_name = "my-lambda"

  # Required: Timeout value of the Lambda in seconds (used to set thresholds)
  lambda_timeout = 30

  # Required: List of ARNs (e.g., SNS topics) to notify when an alarm is triggered
  alarm_actions = [
    "arn:aws:sns:eu-west-2:123456789012:lambda-alerts"
  ]

  # Required: List of ARNs to notify when the alarm returns to OK state
  ok_actions = [
    "arn:aws:sns:eu-west-2:123456789012:lambda-alerts"
  ]

  # Optional: Override the default metric namespace (default is "AWS/Lambda")
  namespace = "AWS/Lambda"
}


```

<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                     | Type     |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_cloudwatch_metric_alarm.lambda_duration_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.lambda_error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm)          | resource |
| [aws_cloudwatch_metric_alarm.lambda_memory_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm)   | resource |

## Inputs

| Name                                                                                          | Description | Type           | Default        | Required |
| --------------------------------------------------------------------------------------------- | ----------- | -------------- | -------------- | :------: |
| <a name="input_alarm_actions"></a> [alarm_actions](#input_alarm_actions)                      | n/a         | `list(string)` | n/a            |   yes    |
| <a name="input_lambda_function_name"></a> [lambda_function_name](#input_lambda_function_name) | n/a         | `string`       | n/a            |   yes    |
| <a name="input_lambda_name"></a> [lambda_name](#input_lambda_name)                            | n/a         | `string`       | n/a            |   yes    |
| <a name="input_lambda_timeout"></a> [lambda_timeout](#input_lambda_timeout)                   | n/a         | `number`       | n/a            |   yes    |
| <a name="input_namespace"></a> [namespace](#input_namespace)                                  | n/a         | `string`       | `"AWS/Lambda"` |    no    |
| <a name="input_ok_actions"></a> [ok_actions](#input_ok_actions)                               | n/a         | `list(string)` | n/a            |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
