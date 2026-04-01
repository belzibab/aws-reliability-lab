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

module "rds" {
  source             = "../modules/rds"
  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  db_password        = var.db_password
}

module "route53" {
  source               = "../modules/route53"
  project              = var.project
  environment          = var.environment
  primary_alb_dns_name = module.ecs.alb_dns_name
  primary_alb_zone_id  = "Z35SXDOTRQ7X7K"
}

module "observability" {
  source                  = "../modules/observability"
  project                 = var.project
  environment             = var.environment
  ecs_cluster_name        = module.ecs.ecs_cluster_name
  ecs_service_name        = module.ecs.ecs_service_name
  alb_arn_suffix          = "app/aws-reliability-lab-dev-alb/8b0193475e18dd63"
  target_group_arn_suffix = "targetgroup/aws-reliability-lab-dev-tg/3e6a3eb3d49d90b2"
  alarm_email             = var.alarm_email
}
