# Outputs se irán agregando conforme crezca la infra
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.ecs.alb_dns_name
}
