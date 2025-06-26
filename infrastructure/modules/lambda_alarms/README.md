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

<!-- END_TF_DOCS -->
