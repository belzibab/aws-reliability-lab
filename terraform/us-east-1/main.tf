terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "aws-reliability-lab-tfstate"
    key            = "us-east-1/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aws-reliability-lab-tflock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
module "vpc" {
  source      = "../modules/vpc"
  project     = var.project
  environment = var.environment
}
