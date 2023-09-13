module "sqs-splunk-queue" {
  source = "./modules/sqs"
  name   = "splunk-queue"
}

module "sqs-nems-queue" {
  source = "./modules/sqs"
  name   = "nems-queue"
}

module "sqs-nems-queue-subscription" {
  source         = "./modules/sns"
  topic_name     = "create_doc-alarms-topic"
  topic_protocol = "sqs"
  topic_endpoint = module.sqs-nems-queue.endpoint
  delivery_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudwatch.amazonaws.com"
        },
        "Action" : [
          "SNS:Publish",
        ],
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:cloudwatch:eu-west-2:${data.aws_caller_identity.current.account_id}:alarm:*"
          }
        }
        "Resource" : "*"
      }
    ]
  })
}