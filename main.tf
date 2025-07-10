# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}


# Use a for_each loop to process each function name from the input variable
# This creates a set of data sources and resources for each function.
module "lambda_backup" {
  source   = "./modules/backup_logic" 
  for_each = toset(var.lambda_function_names)

  function_name = each.key
  backup_bucket = var.backup_bucket
  backup_folder = var.backup_folder
}