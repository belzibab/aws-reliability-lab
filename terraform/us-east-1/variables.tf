variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name used for tagging"
  type        = string
  default     = "aws-reliability-lab"
}

variable "environment" {
  description = "Environment (dev, prod)"
  type        = string
  default     = "dev"
}
variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}
