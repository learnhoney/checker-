# terraform.tfvars

#functions to backup 
lambda_function_names = [
  "my-first-lambda-function",
  "my-second-lambda-function",
  "my-sqs-processor-function"
]

backup_bucket = "testing-backups-lambda"
backup_folder = "test-folder-terraform"
aws_region    = "us-east-1"