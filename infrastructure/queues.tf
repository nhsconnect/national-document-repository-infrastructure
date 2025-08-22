module "sqs-lg-bulk-upload-metadata-queue" {
  source               = "./modules/sqs"
  name                 = "lg-bulk-upload-metadata-queue.fifo"
  max_size_message     = 256 * 1024        # allow message size up to 256 KB
  message_retention    = 60 * 60 * 24 * 14 # 14 days
  environment          = var.environment
  owner                = var.owner
  max_visibility       = 1020
  enable_fifo          = true
  enable_deduplication = true
  delay                = 60
}

module "sqs-lg-bulk-upload-invalid-queue" {
  source            = "./modules/sqs"
  name              = "lg-bulk-upload-invalid-queue"
  max_size_message  = 256 * 1024        # 256 KB
  message_retention = 60 * 60 * 24 * 14 # 14 days
  environment       = var.environment
  owner             = var.owner
  max_visibility    = 1020
}

module "v2-sqs-lg-bulk-upload-metadata-queue" {
  count                = local.is_sandbox || (terraform.workspace == "ndr-dev") ? 1 : 0
  source               = "./modules/sqs"
  name                 = "v2-lg-bulk-upload-metadata-queue.fifo"
  max_size_message     = 256 * 1024
  message_retention    = 60 * 60 * 24 * 14
  environment          = var.environment
  owner                = var.owner
  max_visibility       = 1020
  enable_fifo          = true
  enable_deduplication = true
  delay                = 60
}

module "v2-sqs-lg-bulk-upload-invalid-queue" {
  count             = local.is_sandbox || (terraform.workspace == "ndr-dev") ? 1 : 0
  source            = "./modules/sqs"
  name              = "v2-lg-bulk-upload-invalid-queue"
  max_size_message  = 256 * 1024        # 256 KB
  message_retention = 60 * 60 * 24 * 14 # 14 days
  environment       = var.environment
  owner             = var.owner
  max_visibility    = 1020
}
