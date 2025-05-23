module "document_reference_dynamodb_table" {
  source                         = "./modules/dynamo_db"
  table_name                     = var.docstore_dynamodb_table_name
  hash_key                       = "ID"
  deletion_protection_enabled    = local.is_production
  stream_enabled                 = true
  stream_view_type               = "OLD_IMAGE"
  ttl_enabled                    = true
  ttl_attribute_name             = "TTL"
  point_in_time_recovery_enabled = !local.is_sandbox

  attributes = [
    {
      name = "ID"
      type = "S"
    },
    {
      name = "FileLocation"
      type = "S"
    },
    {
      name = "NhsNumber"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "FileLocationsIndex"
      hash_key        = "FileLocation"
      projection_type = "ALL"
    },
    {
      name            = "NhsNumberIndex"
      hash_key        = "NhsNumber"
      projection_type = "ALL"
    }
  ]

  environment = var.environment
  owner       = var.owner
}

module "cloudfront_edge_dynamodb_table" {
  source                         = "./modules/dynamo_db"
  table_name                     = var.cloudfront_edge_table_name
  hash_key                       = "ID"
  deletion_protection_enabled    = local.is_production
  stream_enabled                 = false
  ttl_enabled                    = true
  ttl_attribute_name             = "TTL"
  point_in_time_recovery_enabled = !local.is_sandbox

  attributes = [
    {
      name = "ID"
      type = "S"
    }
  ]

  environment = var.environment
  owner       = var.owner
}

module "lloyd_george_reference_dynamodb_table" {
  source                         = "./modules/dynamo_db"
  table_name                     = var.lloyd_george_dynamodb_table_name
  hash_key                       = "ID"
  deletion_protection_enabled    = local.is_production
  stream_enabled                 = true
  stream_view_type               = "OLD_IMAGE"
  ttl_enabled                    = true
  ttl_attribute_name             = "TTL"
  point_in_time_recovery_enabled = !local.is_sandbox

  attributes = [
    {
      name = "ID"
      type = "S"
    },
    {
      name = "FileLocation"
      type = "S"
    },
    {
      name = "NhsNumber"
      type = "S"
    },
    {
      name = "CurrentGpOds"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "FileLocationsIndex"
      hash_key        = "FileLocation"
      projection_type = "ALL"
    },
    {
      name            = "NhsNumberIndex"
      hash_key        = "NhsNumber"
      projection_type = "ALL"
    },
    {
      name            = "OdsCodeIndex"
      hash_key        = "CurrentGpOds"
      projection_type = "ALL"
    }
  ]

  environment = var.environment
  owner       = var.owner
}

module "unstitched_lloyd_george_reference_dynamodb_table" {
  source                         = "./modules/dynamo_db"
  table_name                     = var.unstitched_lloyd_george_dynamodb_table_name
  hash_key                       = "ID"
  deletion_protection_enabled    = local.is_production
  stream_enabled                 = true
  stream_view_type               = "OLD_IMAGE"
  ttl_enabled                    = true
  ttl_attribute_name             = "TTL"
  point_in_time_recovery_enabled = !local.is_sandbox

  attributes = [
    {
      name = "ID"
      type = "S"
    },
    {
      name = "FileLocation"
      type = "S"
    },
    {
      name = "NhsNumber"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "FileLocationsIndex"
      hash_key        = "FileLocation"
      projection_type = "ALL"
    },
    {
      name            = "NhsNumberIndex"
      hash_key        = "NhsNumber"
      projection_type = "ALL"
    }
  ]

  environment = var.environment
  owner       = var.owner
}

module "zip_store_reference_dynamodb_table" {
  source                      = "./modules/dynamo_db"
  table_name                  = var.zip_store_dynamodb_table_name
  hash_key                    = "ID"
  deletion_protection_enabled = local.is_production
  stream_enabled              = true
  ttl_enabled                 = false

  attributes = [
    {
      name = "ID"
      type = "S"
    },
    {
      name = "JobId"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "JobIdIndex"
      hash_key        = "JobId"
      projection_type = "ALL"
    }
  ]

  environment = var.environment
  owner       = var.owner
}

module "stitch_metadata_reference_dynamodb_table" {
  source                      = "./modules/dynamo_db"
  table_name                  = var.stitch_metadata_dynamodb_table_name
  hash_key                    = "ID"
  deletion_protection_enabled = local.is_production
  stream_enabled              = true
  ttl_enabled                 = true
  ttl_attribute_name          = "ExpireAt"

  attributes = [
    {
      name = "ID"
      type = "S"
    },
    {
      name = "NhsNumber"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "NhsNumberIndex"
      hash_key        = "NhsNumber"
      projection_type = "ALL"
    }
  ]

  environment = var.environment
  owner       = var.owner
}

module "auth_state_dynamodb_table" {
  source                      = "./modules/dynamo_db"
  table_name                  = var.auth_state_dynamodb_table_name
  hash_key                    = "State"
  deletion_protection_enabled = local.is_production
  stream_enabled              = false
  ttl_enabled                 = true
  ttl_attribute_name          = "TimeToExist"
  attributes = [
    {
      name = "State"
      type = "S"
    },
  ]

  global_secondary_indexes = [
    {
      name            = "StateIndex"
      hash_key        = "State"
      projection_type = "ALL"
    }
  ]

  environment = var.environment
  owner       = var.owner
}

module "auth_session_dynamodb_table" {
  source                      = "./modules/dynamo_db"
  table_name                  = var.auth_session_dynamodb_table_name
  hash_key                    = "NDRSessionId"
  deletion_protection_enabled = local.is_production
  stream_enabled              = false
  ttl_enabled                 = true
  ttl_attribute_name          = "TimeToExist"
  attributes = [
    {
      name = "NDRSessionId"
      type = "S"
    },
  ]

  global_secondary_indexes = [
    {
      name            = "NDRSessionIdIndex"
      hash_key        = "NDRSessionId"
      projection_type = "ALL"
    }
  ]

  environment = var.environment
  owner       = var.owner
}

module "bulk_upload_report_dynamodb_table" {
  source                         = "./modules/dynamo_db"
  table_name                     = var.bulk_upload_report_dynamodb_table_name
  hash_key                       = "ID"
  deletion_protection_enabled    = local.is_production
  stream_enabled                 = false
  ttl_enabled                    = false
  point_in_time_recovery_enabled = !local.is_sandbox

  attributes = [
    {
      name = "ID"
      type = "S"
    },
    {
      name = "NhsNumber"
      type = "S"
    },
    {
      name = "Timestamp"
      type = "N"
    },
    {
      name = "Date"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "NhsNumberIndex"
      hash_key        = "NhsNumber"
      projection_type = "ALL"
    },
    {
      name            = "TimestampIndex"
      hash_key        = "Date"
      range_key       = "Timestamp"
      projection_type = "ALL"
    }
  ]

  environment = var.environment
  owner       = var.owner
}

module "statistics_dynamodb_table" {
  source                         = "./modules/dynamo_db"
  table_name                     = var.statistics_dynamodb_table_name
  hash_key                       = "Date"
  sort_key                       = "StatisticID"
  deletion_protection_enabled    = local.is_production
  stream_enabled                 = false
  ttl_enabled                    = false
  point_in_time_recovery_enabled = !local.is_sandbox

  attributes = [
    {
      name = "Date"
      type = "S"
    },
    {
      name = "StatisticID"
      type = "S"
    },
    {
      name = "OdsCode"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "OdsCodeIndex"
      hash_key        = "OdsCode"
      range_key       = "Date"
      projection_type = "ALL"
    }
  ]

  environment = var.environment
  owner       = var.owner
}

module "access_audit_dynamodb_table" {
  source                         = "./modules/dynamo_db"
  table_name                     = var.access_audit_dynamodb_table_name
  hash_key                       = "Type"
  sort_key                       = "ID"
  deletion_protection_enabled    = local.is_production
  stream_enabled                 = false
  ttl_enabled                    = false
  point_in_time_recovery_enabled = !local.is_sandbox

  attributes = [
    {
      name = "Type"
      type = "S"
    },
    {
      name = "ID"
      type = "S"
    },
    {
      name = "UserSessionID"
      type = "S"
    },
    {
      name = "UserID"
      type = "S"
    },
    {
      name = "UserOdsCode"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "UserSessionIDIndex"
      hash_key        = "UserSessionID"
      projection_type = "ALL"
    },
    {
      name            = "UserIDIndex"
      hash_key        = "UserID"
      projection_type = "ALL"
    },
    {
      name            = "UserOdsCodeIndex"
      hash_key        = "UserOdsCode"
      projection_type = "ALL"
    }
  ]

  environment = var.environment
  owner       = var.owner
}

module "alarm_state_history_table" {
  source                         = "./modules/dynamo_db"
  table_name                     = var.alarm_state_history_table_name
  hash_key                       = "AlarmNameMetric"
  sort_key                       = "TimeCreated"
  deletion_protection_enabled    = local.is_production
  point_in_time_recovery_enabled = !local.is_sandbox
  stream_enabled                 = false
  ttl_enabled                    = true
  ttl_attribute_name             = "TimeToExist"

  attributes = [
    {
      name = "AlarmNameMetric",
      type = "S"
    },
    {
      name = "TimeCreated"
      type = "N"
    }
  ]

  # global_secondary_indexes = [
  #   {
  #     name            = "AlarmNameIndex"
  #     hash_key        = "AlarmName"
  #     projection_type = "ALL"
  # }]

  environment = var.environment
  owner       = var.owner
}