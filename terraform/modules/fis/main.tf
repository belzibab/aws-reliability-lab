locals {
  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# IAM role para FIS
resource "aws_iam_role" "fis" {
  name = "${var.project}-${var.environment}-fis-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "fis.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "fis" {
  name = "${var.project}-${var.environment}-fis-policy"
  role = aws_iam_role.fis.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:ListTasks",
          "ecs:DescribeTasks",
          "ecs:StopTask"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["cloudwatch:DescribeAlarms"]
        Resource = "*"
      }
    ]
  })
}

# Stop condition — detiene el experimento si hay alarma activa
resource "aws_cloudwatch_metric_alarm" "fis_stop" {
  alarm_name          = "${var.project}-${var.environment}-fis-stop-condition"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 50
  alarm_description   = "FIS stop condition — too many 5xx errors"
  treat_missing_data  = "notBreaching"

  tags = local.tags
}

# Experimento FIS — mata una tarea ECS
resource "aws_fis_experiment_template" "ecs_task_kill" {
  description = "Kill one ECS task and verify auto-recovery"
  role_arn    = aws_iam_role.fis.arn

  stop_condition {
    source = "aws:cloudwatch:alarm"
    value  = aws_cloudwatch_metric_alarm.fis_stop.arn
  }

  action {
    name      = "kill-ecs-task"
    action_id = "aws:ecs:stop-task"

    target {
      key   = "Tasks"
      value = "ecs-tasks"
    }
  }

  target {
    name           = "ecs-tasks"
    resource_type  = "aws:ecs:task"
    selection_mode = "COUNT(1)"

    resource_arns = []

    resource_tag {
      key   = "Project"
      value = var.project
    }

    filter {
      path   = "clusterArn"
      values = [var.ecs_cluster_arn]
    }
  }

  tags = local.tags
}
