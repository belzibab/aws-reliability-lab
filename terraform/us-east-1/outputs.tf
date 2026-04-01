output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.ecs.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.cluster_endpoint
}

output "health_check_id" {
  description = "Route53 health check ID"
  value       = module.route53.health_check_id
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = module.observability.dashboard_url
}
