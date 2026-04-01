# Outputs se irán agregando conforme crezca la infra
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.ecs.alb_dns_name
}
output "rds_endpoint" {
  description = "RDS cluster endpoint"
  value       = module.rds.cluster_endpoint
}
output "health_check_id" {
  description = "Route53 health check ID"
  value       = module.route53.health_check_id
}
