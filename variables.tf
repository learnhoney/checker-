# /terraform-lambda-backup/modules/backup_logic/variables.tf

variable "function_name" {
  description = "The name of the single Lambda function to back up."
  type        = string
}

variable "backup_bucket" {
  description = "The S3 bucket for the backup."
  type        = string
}

variable "backup_folder" {
  description = "The S3 folder for the backup."
  type        = string
}