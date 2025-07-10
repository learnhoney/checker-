# /terraform-lambda-backup/modules/backup_logic/outputs.tf

output "config_backup_s3_uri" {
  description = "The S3 URI of the backed-up config.json file."
  value       = "s3://${aws_s3_object.config_backup.bucket}/${aws_s3_object.config_backup.key}"
}

output "code_backup_s3_uri" {
  description = "The S3 URI of the backed-up code.zip file."
  # We use a splat (*) to handle the case where the resource is not created (count = 0)
  value       = try("s3://${aws_s3_object_copy.code_backup[0].bucket}/${aws_s3_object_copy.code_backup[0].key}", "N/A - Code not in S3")
}