output "cluster_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.address
}

output "cluster_reader_endpoint" {
  description = "RDS instance endpoint (same as writer for single instance)"
  value       = aws_db_instance.main.address
}

output "cluster_identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.main.identifier
}
