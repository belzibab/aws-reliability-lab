output "experiment_template_id" {
  description = "FIS experiment template ID"
  value       = aws_fis_experiment_template.ecs_task_kill.id
}

output "fis_role_arn" {
  description = "FIS IAM role ARN"
  value       = aws_iam_role.fis.arn
}
