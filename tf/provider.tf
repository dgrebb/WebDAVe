provider "aws" {
  region     = var.REGION
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  # uncomment if you'd like to use s3 to store Terraform state
  # backend "s3" {}
}
