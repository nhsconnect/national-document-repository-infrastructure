# Lambda CloudWatch Alarms Module

## Features

- CloudWatch alarm for high **duration** (exec time vs. timeout)
- CloudWatch alarm for **errors** (failed invocations)
- CloudWatch alarm for high **memory usage**
- Configurable `alarm_actions` and `ok_actions`
- Supports custom CloudWatch namespace (default: `AWS/Lambda`)

---

## Usage

```hcl
module "lambda_alarms" {
  source = "./modules/lambda-alarms"

  # Required: The name of the Lambda function to monitor
  lambda_function_name = "my-lambda-function"

  # Required: Short identifier used in alarm naming
  lambda_name = "my-lambda"

  # Required: Timeout value of the Lambda in seconds
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

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.lambda_duration_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.lambda_error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.lambda_memory_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | List of ARNs (e.g., SNS topics) to notify when a CloudWatch alarm is triggered. | `list(string)` | n/a | yes |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | The name of the Lambda function to monitor. | `string` | n/a | yes |
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | Short identifier used in CloudWatch alarm naming. | `string` | n/a | yes |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Timeout value of the Lambda function in seconds. | `number` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | CloudWatch metric namespace. Defaults to 'AWS/Lambda' if not specified. | `string` | `"AWS/Lambda"` | no |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | List of ARNs to notify when a CloudWatch alarm returns to the OK state. | `list(string)` | n/a | yes |
## Outputs

No outputs.
<!-- END_TF_DOCS -->
