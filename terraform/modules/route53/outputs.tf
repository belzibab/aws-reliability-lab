output "health_check_id" {
  description = "Route53 health check ID"
  value       = aws_route53_health_check.primary.id
}

output "health_check_status" {
  description = "Route53 health check status URL"
  value       = "https://console.aws.amazon.com/route53/healthchecks/home#/"
}
