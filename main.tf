# /terraform-lambda-backup/modules/backup_logic/main.tf

# 1. DATA SOURCES: Read information about the existing Lambda

# Data source to get the main configuration of the Lambda function
data "aws_lambda_function" "existing_lambda" {
  function_name = var.function_name
}

# Data source to get the resource-based policy (for S3, EventBridge triggers)
# We use try() to prevent errors if a function has no policy.
data "aws_lambda_policy" "existing_policy" {
  function_name = data.aws_lambda_function.existing_lambda.function_name
  depends_on    = [data.aws_lambda_function.existing_lambda]
}

# Data source to get Event Source Mappings (for SQS, DynamoDB triggers)
data "aws_lambda_event_source_mappings" "existing_esm" {
  function_name = data.aws_lambda_function.existing_lambda.function_name
  depends_on    = [data.aws_lambda_function.existing_lambda]
}


# 2. RESOURCES: Create the backup files in S3

# Resource to create the config.json file and upload it to S3
resource "aws_s3_object" "config_backup" {
  bucket = var.backup_bucket
  key    = "${var.backup_folder}/${var.function_name}-config.json"

  # The content is a dynamically generated JSON string
  content = jsonencode({
    # Basic configuration from the aws_lambda_function data source
    FunctionName = data.aws_lambda_function.existing_lambda.function_name
    FunctionArn  = data.aws_lambda_function.existing_lambda.arn
    Runtime      = data.aws_lambda_function.existing_lambda.runtime
    Role         = data.aws_lambda_function.existing_lambda.role
    Handler      = data.aws_lambda_function.existing_lambda.handler
    Timeout      = data.aws_lambda_function.existing_lambda.timeout
    MemorySize   = data.aws_lambda_function.existing_lambda.memory_size
    LastModified = data.aws_lambda_function.existing_lambda.last_modified
    CodeSize     = data.aws_lambda_function.existing_lambda.source_code_size
    # Combine triggers from both policies and event source mappings
    Triggers = concat(
      # Triggers from Resource-Based Policy (S3, EventBridge, etc.)
      [for statement in try(jsondecode(data.aws_lambda_policy.existing_policy.policy).Statement, []) : {
        Type      = try(split(":", statement.Principal.Service)[0], "Unknown")
        SourceArn = try(statement.Condition.ArnLike["aws:SourceArn"], "N/A")
        EventType = "Resource-Based Policy"
      }],
      # Triggers from Event Source Mappings (SQS, DynamoDB, etc.)
      [for mapping in data.aws_lambda_event_source_mappings.existing_esm.event_source_mappings : {
        Type      = try(split(":", mapping.event_source_arn)[2], "Unknown")
        SourceArn = mapping.event_source_arn
        State     = mapping.state
        BatchSize = mapping.batch_size
        EventType = "Event Source Mapping"
      }]
    )
  })
}

# Resource to copy the Lambda function's code zip file to the backup bucket
# NOTE: This works perfectly if the Lambda was deployed from an S3 bucket.
resource "aws_s3_object_copy" "code_backup" {
  # Only create this resource if the lambda code source is an S3 bucket
  count = data.aws_lambda_function.existing_lambda.s3_bucket != null ? 1 : 0

  bucket = var.backup_bucket
  key    = "${var.backup_folder}/${var.function_name}-code.zip"

  # Source from the Lambda's own configuration
  source = "${data.aws_lambda_function.existing_lambda.s3_bucket}/${data.aws_lambda_function.existing_lambda.s3_key}"
}