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
module "ecs" {
  source             = "../modules/ecs"
  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  container_image    = "668774618240.dkr.ecr.us-east-1.amazonaws.com/aws-reliability-lab:latest"
}
