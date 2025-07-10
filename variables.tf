# variables.tf

variable "lambda_function_names" {
  description = "A list of the exact names of the Lambda functions to back up."
  type        = list(string)
}

variable "backup_bucket" {
  description = "The name of the S3 bucket to store the backups in."
  type        = string
}

variable "backup_folder" {
  description = "The folder within the S3 bucket to store the backups."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where the Lambda functions exist."
  type        = string
}